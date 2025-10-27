# frozen_string_literal: true

require 'image_optim/worker'
require 'image_optim/option_helpers'

class ImageOptim
  class Worker
    # WebP encoder/optimizer
    # https://developers.google.com/speed/webp
    class Cwebp < Worker
      ALLOW_LOSSY_OPTION =
      option(:allow_lossy, false, 'Allow lossy compression'){ |v| !!v }

      QUALITY_OPTION =
      option(:quality, 75, 'Compression quality ' \
                           '`0`..`100`, ignored in lossless mode') do |v, opt_def|
        if allow_lossy
          OptionHelpers.limit_with_range(v.to_i, 0..100)
        else
          if v != opt_def.default
            warn "#{self.class.bin_sym} #{opt_def.name} #{v} ignored " \
                 'in lossless mode'
          end
          opt_def.default
        end
      end

      METHOD_OPTION =
      option(:method, 4, 'Compression method ' \
                         '`0` - fast, ' \
                         '`6` - slower/better') do |v|
        OptionHelpers.limit_with_range(v.to_i, 0..6)
      end

      ALPHA_QUALITY_OPTION =
      option(:alpha_quality, 100, 'Alpha channel compression quality ' \
                                  '`0`..`100`') do |v|
        OptionHelpers.limit_with_range(v.to_i, 0..100)
      end

      STRIP_OPTION =
      option(:strip, :all, Array, 'List of metadata to strip: ' \
                                  '`:exif`, ' \
                                  '`:icc`, ' \
                                  '`:xmp`, ' \
                                  '`:none` or ' \
                                  '`:all`') do |v|
        values = Array(v).map(&:to_s)
        known_values = %w[exif icc xmp none all]
        unknown_values = values - known_values
        unless unknown_values.empty?
          warn "Unknown metadata for cwebp: #{unknown_values.join(', ')}"
        end
        values & known_values
      end

      def image_formats
        [:webp]
      end

      def optimize(src, dst, options = {})
        args = %W[
          -o #{dst}
          -m #{method}
          -alpha_q #{alpha_quality}
        ]

        if allow_lossy
          args.unshift("-q #{quality}")
        else
          args.unshift('-lossless')
        end

        # Handle metadata stripping
        if strip.include?('all')
          args.unshift('-metadata', 'none')
        elsif strip.include?('none')
          args.unshift('-metadata', 'all')
        else
          # Build metadata string from what to keep
          metadata_to_keep = %w[exif icc xmp] - strip
          unless metadata_to_keep.empty?
            args.unshift('-metadata', metadata_to_keep.join(','))
          else
            args.unshift('-metadata', 'none')
          end
        end

        args.push('--')
        args.push(src.to_s)

        execute(:cwebp, args, options) && optimized?(src, dst)
      end
    end
  end
end

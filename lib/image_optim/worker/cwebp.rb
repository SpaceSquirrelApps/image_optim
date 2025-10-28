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
      option(:method, 6, 'Compression method ' \
                         '`0` - fast, ' \
                         '`6` - slower/better') do |v|
        OptionHelpers.limit_with_range(v.to_i, 0..6)
      end

      MT_OPTION =
      option(:mt, true, 'Enable multi-threaded encoding'){ |v| !!v }

      def image_formats
        [:webp]
      end

      def optimize(src, dst, options = {})
        args = []

        # Add multi-threading if enabled
        args.push('-mt') if mt

        # Quality/lossless setting
        if allow_lossy
          args.push('-q', quality.to_s)
        else
          args.push('-near_lossless', '0')
        end

        # Compression method
        args.push('-m', method.to_s)

        # Output file
        args.push('-o', dst.to_s)

        # Input file
        args.push('--')
        args.push(src.to_s)

        execute(:cwebp, args, options) && optimized?(src, dst)
      end
    end
  end
end

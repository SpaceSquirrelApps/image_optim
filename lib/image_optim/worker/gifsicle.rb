require 'image_optim/worker'

class ImageOptim
  class Worker
    # http://www.lcdf.org/gifsicle/
    class Gifsicle < Worker
      # If interlace specified initialize one instance
      # Otherwise initialize two, one with interlace off and one with on
      def self.init(image_optim, options = {})
        return super if options.key?(:interlace)

        [false, true].map do |interlace|
          new(image_optim, options.merge(:interlace => interlace))
        end
      end

      INTERLACE_OPTION =
      option(:interlace, false, TrueFalseNil, 'Interlace: '\
          '`true` - interlace on, '\
          '`false` - interlace off, '\
          '`nil` - as is in original image '\
          '(defaults to running two instances, one with interlace off and '\
          'one with on)') do |v|
        TrueFalseNil.convert(v)
      end

      LEVEL_OPTION =
      option(:level, 3, 'Compression level: '\
          '`1` - light and fast, '\
          '`2` - normal, '\
          '`3` - heavy (slower)') do |v|
        OptionHelpers.limit_with_range(v.to_i, 1..3)
      end

      ALLOW_LOSSY_OPTION =
      option(:allow_lossy, false, 'Allow quality option') { |v| !!v }

      # Adjust --lossy argument to quality you want (30 is very light compression, 200 is heavy)
      QUALITY_OPTION =
      option(:quality, 95, 'Shrink output file size at the cost of artifacts and noise') do |value|
        next if value.nil?

        next unless allow_lossy

        value = OptionHelpers.limit_with_range(value.to_i, 65..95)
        value = 95 - value
        (value * 5) + 50
      end

      CAREFUL_OPTION =
      option(:careful, false, 'Avoid bugs with some software'){ |v| !!v }

      def optimize(src, dst)
        args = %W[
          --output=#{dst}
          --no-comments
          --no-names
          --same-delay
          --same-loopcount
          --no-warnings
          --
          #{src}
        ]

        if resolve_bin!(:gifsicle).version >= '1.85'
          args.unshift '--no-extensions', '--no-app-extensions'
        end

        unless interlace.nil?
          args.unshift interlace ? '--interlace' : '--no-interlace'
        end
        args.unshift '--careful' if careful
        args.unshift "--optimize=#{level}" if level
        args.unshift "--lossy=#{quality}" if allow_lossy
        execute(:gifsicle, *args) && optimized?(src, dst)
      end
    end
  end
end

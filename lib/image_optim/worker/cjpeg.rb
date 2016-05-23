require 'image_optim/worker'
require 'image_optim/option_helpers'

class ImageOptim
  class Worker
    class Cjpeg < Worker

      # Initialize only if allow_lossy
      def self.init(image_optim, options = {})
        super if options[:allow_lossy]
      end

      QUALITY_OPTION =
      option(:quality, 90, "JPEG quality preset") do |v|
        OptionHelpers.limit_with_range(v.to_i, 1..100)
      end

      def image_formats
        [:jpeg]
      end

      def run_order
        2
      end

      def optimize(src, dst)
         # /usr/local/Cellar/mozjpeg/3.1/bin/cjpeg -quality 90 -optimize -progressive -outfile 1moz.jpg 1.jpg
        args = %W[
          -quality #{quality}
          -optimize
          -progressive
          -outfile #{dst}
          #{src}
        ]        

        execute(:cjpeg, *args) && optimized?(src, dst)
      end
    end
  end
end

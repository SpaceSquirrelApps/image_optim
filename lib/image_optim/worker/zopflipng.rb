require 'image_optim/worker'
require 'image_optim/option_helpers'

class ImageOptim
  class Worker
    class Zopflipng < Worker
      ITERATIONS_OPTION = option(:iterations, 15, '--iterations=') do |v|
        OptionHelpers.limit_with_range(v.to_i, 1..15)
      end

      def image_formats
        [:png]
      end

      def run_order
        2
      end

      def optimize(src, dst)
        args = %W[
          --iterations=#{iterations}
          #{src}
          #{dst}
        ]        

        execute(:zopflipng, *args) && optimized?(src, dst)
      end
    end
  end
end

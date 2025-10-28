# frozen_string_literal: true

require 'image_optim/worker'

class ImageOptim
  class Worker
    # WebP decoder - converts WebP to PNG
    # https://developers.google.com/speed/webp
    class Dwebp < Worker
      # dwebp converts WebP to PNG format
      def image_formats
        [:png]
      end

      # Run early to decode WebP before other PNG optimizers
      def run_order
        -5
      end

      def optimize(src, dst, options = {})
        # Only process WebP files
        return false unless src.to_s.end_with?('.webp')

        args = %W[
          #{src}
          -o #{dst}
        ]

        execute(:dwebp, args, options)
      end
    end
  end
end

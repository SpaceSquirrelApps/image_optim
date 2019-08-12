require 'image_optim/worker'

class ImageOptim
  class Worker
    # http://www.ijg.org/
    #
    # Uses jpegtran through jpegrescan if enabled, jpegrescan is vendored with
    # this gem
    class Jpegtran < Worker
      STRIP_TAGS =
      option(:strip_tags, false, 'Remove optional metadata') { |v| !!v }

      PROGRESSIVE_OPTION =
      option(:progressive, true, 'Create progressive JPEG file'){ |v| !!v }

      JPEGRESCAN_OPTION =
      option(:jpegrescan, true, 'Use jpegtran through jpegrescan, '\
          'ignore progressive option'){ |v| !!v }

      def used_bins
        jpegrescan ? [:jpegtran, :jpegrescan] : [:jpegtran]
      end

      def optimize(src, dst)
        if jpegrescan
          args = [src.to_s, dst.to_s]
          args.unshift('-s') if strip_tags
          resolve_bin!(:jpegtran)
          execute(:jpegrescan, *args) && optimized?(src, dst)
        else
          args = %W[
            -optimize
            -outfile #{dst}
            -copy #{strip_tags ? 'none' : 'all'}
          ]
          args.push('-progressive') if progressive
          args.push(src.to_s)

          execute(:jpegtran, *args) && optimized?(src, dst)
        end
      end
    end
  end
end

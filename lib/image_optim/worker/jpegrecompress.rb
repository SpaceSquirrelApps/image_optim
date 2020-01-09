require 'image_optim/worker'
require 'image_optim/option_helpers'

class ImageOptim
  class Worker
    # https://github.com/danielgtaylor/jpeg-archive#jpeg-recompress
    class Jpegrecompress < Worker
      ALLOW_LOSSY_OPTION = option(:allow_lossy, false, 'Allow worker, it is always lossy') { |v| !!v }
      STRIP_TAGS = option(:strip_tags, false, 'Remove optional metadata') { |v| !!v }
      METHODS = %w[mpe ssim ms-ssim smallfry].freeze
      LOOPS = option(:loops, 6, 'Set the number of runs to attempt') { |v| OptionHelpers.limit_with_range(v.to_i, 1..16) }
      QUALITY_MIN = option(:quality_min, 50, 'Minimum JPEG quality') { |v| OptionHelpers.limit_with_range(v.to_i, 30..70) }
      QUALITY_MAX = option(:quality_max, 90, 'Maximum JPEG quality') { |v| OptionHelpers.limit_with_range(v.to_i, 70..100) }
      COMPRESSION_METHOD = option(:compression_method, 'smallfry', 'Set comparison method') do |v|
        selected = v.to_s
        METHODS.include?(selected) ? selected : 'smallfry'
      end
      QUALITY_NAMES = %i[low medium high veryhigh].freeze

      # Initialize only if allow_lossy
      def self.init(image_optim, options = {})
        super if options[:allow_lossy]
      end

      def used_bins
        [:'jpeg-recompress']
      end

      # Run early as lossy worker
      def run_order
        -5
      end

      def optimize(src, dst)
        args = %W[
          --min #{ quality_min }
          --max #{ quality_max }
          --no-copy
          --method #{ compression_method }
          --loops #{ loops }
          --accurate
        ]

        args.push('--strip') if strip_tags
        args.push(src)
        args.push(dst)

        execute(:'jpeg-recompress', *args) && optimized?(src, dst)
      end
    end
  end
end

require 'image_optim/worker'
require 'image_optim/option_helpers'

class ImageOptim
  class Worker
    # https://github.com/shssoichiro/oxipng
    class Oxipng < Worker
      OPTIMIZATION_OPTION = option(:optimiation, 2, 'Optimization level - Default: 2 [possible values: 0..6]') do |v|
        OptionHelpers.limit_with_range(v.to_i, 0..6)
      end

      DELTA_FILTERS_OPTION = option(:delta_filters, 0.5, 'Optimization level - Default: 0,5 [possible values: 0..5]') do |v|
        value = v.to_f
        (value % 0.5).zero? ? value : 0.5
      end

      ALPHA_OPTION = option(:alpha, false, 'Perform additional alpha optimizations') { |v| !!v }
      ZOPFLI_OPTION = option(:zopfli, false, 'Use the slower but better compressing Zopfli algorithm') { |v| !!v }
      FIX_OPTION = option(:fix, false, 'Enable error recovery') { |v| !!v }
      PRESERVE_OPTION = option(:preserve, false, 'Preserve file attributes if possible') { |v| !!v }
      NB_OPTION = option(:nb, false, 'No bit depth reduction') { |v| !!v }
      NC_OPTION = option(:nc, false, 'No color type reduction') { |v| !!v }
      NP_OPTION = option(:np, false, 'No palette reduction') { |v| !!v }
      NX_OPTION = option(:nx, false, 'No reductions') { |v| !!v }
      NZ_OPTION = option(:nz, false, 'No IDAT recoding unless necessary') { |v| !!v }

      TIMEOUT_OPTION = option(:timeout, 10, 'Maximum amount of time, to spend on optimizations (s)') { |v| v.to_i }

      def run_order
        3
      end

      def optimize(src, dst)
        args = %W[
          --strip=safe
          --opt=#{ optimiation }
          --out=#{ dst }
          --filters=#{ delta_filters.to_s.tr('.', ',') }
          --timeout=#{ timeout }
        ]

        args.push('--alpha') if alpha
        args.push('--zopfli') if zopfli
        args.push('--fix') if fix
        args.push('--preserve') if preserve
        args.push('--nb') if nb
        args.push('--nc') if nc
        args.push('--np') if np
        args.push('--nx') if nx
        args.push('--nz') if nz

        args.push(src)

        execute(:oxipng, *args) && optimized?(src, dst)
      end
    end
  end
end

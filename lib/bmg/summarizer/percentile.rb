module Bmg
  class Summarizer
    #
    # Percentile summarizer.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.percentile(:qty, 50).summarize(...)
    #
    class Percentile < Summarizer

      DEFAULT_OPTIONS = {
        :variant => :continuous
      }

      def initialize(*args, &bl)
        @nth = args.find{|a| a.is_a?(Integer) } || 50
        functor = args.find{|a| a.is_a?(Symbol) } || bl
        options = args.select{|a| a.is_a?(Hash) }.inject(DEFAULT_OPTIONS){|memo,opts|
          memo.merge(opts)
        }.dup
        super(functor, options)
      end

      # Returns [] as least value.
      def least()
        []
      end

      # Collects the value
      def _happens(memo, val)
        memo << val
      end

      # Finalizes the computation.
      def finalize(memo)
        return nil if memo.empty?
        index = memo.size.to_f * (@nth.to_f / 100.0)
        floor, ceil = index.floor, index.ceil
        ceil +=1 if floor == ceil
        below = [floor - 1, 0].max
        above = [[ceil - 1, memo.size - 1].min, 0].max
        sorted = memo.sort
        if options[:variant] == :continuous
          (sorted[above] + sorted[below]) / 2.0
        else
          sorted[below]
        end
      end

    end # class Avg

    def self.percentile(*args, &bl)
      Percentile.new(*args, &bl)
    end

    def self.percentile_cont(*args, &bl)
      Percentile.new(*(args + [{:variant => :continuous}]), &bl)
    end

    def self.percentile_disc(*args, &bl)
      Percentile.new(*(args + [{:variant => :discrete}]), &bl)
    end

    def self.median(*args, &bl)
      Percentile.new(*(args + [50]), &bl)
    end

    def self.median_cont(*args, &bl)
      Percentile.new(*(args + [50, {:variant => :continuous}]), &bl)
    end

    def self.median_disc(*args, &bl)
      Percentile.new(*(args + [50, {:variant => :discrete}]), &bl)
    end

  end # class Summarizer
end # module Bmg

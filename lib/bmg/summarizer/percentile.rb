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

      def initialize(attribute = nil, nth = 50, &bl)
        attribute, nth = nil, attribute if attribute.is_a?(Integer)
        super(*[attribute].compact, &bl)
        @nth = nth
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
        index = memo.size * (@nth / 100.0)
        above = [[index.ceil - 1, memo.size - 1].min, 0].max
        below = [index.floor - 1, 0].max
        sorted = memo.sort
        (sorted[above] + sorted[below]) / 2
      end

    end # class Avg

    # Factors percentile summarizer
    def self.percentile(*args, &bl)
      Percentile.new(*args, &bl)
    end

    # Factors median summarizer
    def self.median(*args, &bl)
      Percentile.new(*(args + [50]), &bl)
    end

  end # class Summarizer
end # module Bmg

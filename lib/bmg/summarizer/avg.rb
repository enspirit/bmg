module Bmg
  class Summarizer
    #
    # Average summarizer.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.avg(:qty).summarize(...)
    #
    class Avg < Summarizer

      # Returns [0.0, 0.0] as least value.
      def least()
        [0.0, 0.0]
      end

      # Collects one more value + the sum of all
      def _happens(memo, val) 
        [memo.first + val, memo.last + 1]
      end

      # Finalizes the computation.
      def finalize(memo) 
        memo.first / memo.last 
      end

    end # class Avg

    # Factors an average summarizer
    def self.avg(*args, &bl)
      Avg.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg

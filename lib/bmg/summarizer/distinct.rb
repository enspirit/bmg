module Bmg
  class Summarizer
    #
    # Collect the distinct values as an array.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.distinct(:qty).summarize(...)
    #
    class Distinct < Summarizer

      # Returns [] as least value.
      def least()
        {}
      end

      # Adds val to the memo array
      def _happens(memo, val)
        memo[val] = true
        memo
      end

      def finalize(memo)
        memo.keys
      end

    end # class Distinct

    # Factors a distinct summarizer
    def self.distinct(*args, &bl)
      Distinct.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg

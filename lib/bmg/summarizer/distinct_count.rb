module Bmg
  class Summarizer
    #
    # Collect the count of distinct values.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.distinct_count(:qty).summarize(...)
    #
    class DistinctCount < Summarizer

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
        memo.keys.size
      end

    end # class DistinctCount

    # Factors a distinct count summarizer
    def self.distinct_count(*args, &bl)
      DistinctCount.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg

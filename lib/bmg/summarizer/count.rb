module Bmg
  class Summarizer
    #
    # Count summarizer.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.count.summarize(...)
    #
    class Count < Summarizer

      # Returns 0 as least value.
      def least()
        0
      end

      # Counts one more as new memo
      def happens(memo, tuple) 
        memo + 1
      end

    end # class Count

    # Factors a count summarizer
    def self.count(*args, &bl)
      Count.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg

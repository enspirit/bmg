module Bmg
  class Summarizer
    #
    # Collects the various values as an array.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.collect(:qty).summarize(...)
    #
    class Collect < Summarizer

      # Returns [] as least value.
      def least()
        []
      end

      # Adds val to the memo array
      def _happens(memo, val) 
        memo << val
      end

    end # class Collect

    # Factors a collect summarizer
    def self.collect(*args, &bl)
      Collect.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg

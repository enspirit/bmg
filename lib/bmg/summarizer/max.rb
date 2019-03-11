module Bmg
  class Summarizer
    #
    # Max summarizer.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.max(:qty).summarize(...)
    #
    class Max < Summarizer

      # Returns nil as least value.
      def least()
        nil
      end

      # Keeps the maximum value between memo and val, ignoring nil
      def _happens(memo, val) 
        memo.nil? ? val : (val.nil? ? memo : (memo > val ? memo : val))
      end

    end # class Max

    # Factors a max summarizer
    def self.max(*args, &bl)
      Max.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg

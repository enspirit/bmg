module Bmg
  class Summarizer
    #
    # Min summarizer.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.min(:qty).summarize(...)
    #
    class Min < Summarizer

      # Returns nil as least value.
      def least()
        nil
      end

      # Keep the minimum value between memo and val, ignoring nil
      def _happens(memo, val) 
        memo.nil? ? val : (val.nil? ? memo : (memo < val ? memo : val))
      end

    end # class Min

    # Factors a min summarizer
    def self.min(*args, &bl)
      Min.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg

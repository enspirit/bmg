module Bmg
  class Summarizer
    #
    # Sum summarizer.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.sum(:qty).summarize(...)
    #
    class Sum < Summarizer

      # Returns 0 as least value.
      def least()
        0
      end

      # Keep memo+val as new value
      def _happens(memo, val) 
        memo + (val.nil? ? 0 : val)
      end

    end # class Sum

    # Factors a sum summarizer
    def self.sum(*args, &bl)
      Sum.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg

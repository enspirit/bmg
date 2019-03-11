module Bmg
  class Summarizer
    #
    # Standard deviation summarizer
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.stddev(:qty).summarize(...)
    #
    class Stddev < Variance

      # Finalizes the computation.
      def finalize(memo) 
        Math.sqrt(super(memo))
      end

    end # class Stddev

    # Factors a standard deviation summarizer
    def self.stddev(*args, &bl)
      Stddev.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg

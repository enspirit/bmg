module Bmg
  class Summarizer
    #
    # Variance summarizer
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.variance(:qty).summarize(...)
    #
    class Variance < Summarizer

      # Returns the least value.
      def least()
        [0, 0.0, 0.0]
      end

      # Aggregates on a tuple occurence.
      def _happens(memo, val) 
        count, mean, m2 = memo
        count += 1
        delta = val - mean
        mean  += (delta / count)
        m2    += delta*(val - mean)
        [count, mean, m2]
      end

      # Finalizes the computation.
      def finalize(memo) 
        count, mean, m2 = memo
        m2 / count
      end

    end # class Variance

    # Factors a variance summarizer
    def self.variance(*args, &bl)
      Variance.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg

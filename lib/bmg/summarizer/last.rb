module Bmg
  class Summarizer
    #
    # Last summarizer.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.last(:qty, :order => [:id]).summarize(...)
    #
    class Last < Positional

      def choose(t1, t2)
        t2
      end

    end # class Last

    # Factors a last summarizer
    def self.last(*args, &bl)
      Last.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg

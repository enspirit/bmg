module Bmg
  class Summarizer
    #
    # First summarizer.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.first(:qty, :order => [:id]).summarize(...)
    #
    class First < Positional

      def choose(t1, t2)
        t1
      end

    end # class First

    # Factors a first summarizer
    def self.first(*args, &bl)
      First.new(*args, &bl)
    end

  end # class Summarizer
end # module Bmg

module Bmg
  class Summarizer
    #
    # A summarizer that collects multiple summarization as a wrapped
    # tuple.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.multiple(x: ..., y: ...).summarize(...)
    #
    class Multiple < Summarizer

      def initialize(defs)
        @summarization = Summarizer.summarization(defs)
      end

      # Returns [] as least value.
      def least()
        @summarization.each_pair.each_with_object({}){|(k,v),memo|
          memo[k] = v.least
        }
      end

      # Adds val to the memo array
      def happens(memo, val)
        @summarization.each_pair.each_with_object({}){|(k,v),memo2|
          memo2[k] = v.happens(memo[k], val)
        }
      end

      def finalize(memo)
        @summarization.each_pair.each_with_object({}){|(k,v),memo2|
          memo2[k] = v.finalize(memo[k])
        }
      end

    end # class Multiple

    # Factors a distinct summarizer
    def self.multiple(defs)
      Multiple.new(defs)
    end

  end # class Summarizer
end # module Bmg

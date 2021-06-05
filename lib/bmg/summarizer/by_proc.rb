module Bmg
  class Summarizer
    #
    # Generic summarizer that takes a Proc àla each_with_object.
    #
    # Example:
    #
    #   # direct ruby usage
    #   Bmg::Summarizer.by_proc{|t,memo| ... }.summarize(...)
    #
    class ByProc < Summarizer

      def initialize(least, by_proc)
        @least = least
        @by_proc = by_proc
      end

      # Returns [] as least value.
      def least
        @least
      end

      # Adds val to the memo array
      def happens(memo, val)
        @by_proc.call(val, memo)
      end

      def finalize(memo)
        memo
      end

    end # class ByProc

    # Factors a distinct summarizer
    def self.by_proc(least = nil, proc = nil, &bl)
      least, proc = nil, least if least.is_a?(Proc)
      ByProc.new(least, proc || bl)
    end

  end # class Summarizer
end # module Bmg

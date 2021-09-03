module Bmg
  class Summarizer
    # See First and Last
    class Positional < Summarizer

      def initialize(*args, &block)
        super
        raise ArgumentError, "Missing order" unless options[:order]
        @ordering = Ordering.new(options[:order])
      end
      attr_reader :ordering

      def least
        nil
      end

      def happens(memo, tuple)
        if memo.nil?
          tuple
        else
          c = ordering.call(memo, tuple)
          c <= 0 ? choose(memo, tuple) : choose(tuple, memo)
        end
      end

      def finalize(memo)
        return nil if memo.nil?
        extract_value(memo)
      end

    end # class Positional
  end # class Summarizer
end # module Bmg

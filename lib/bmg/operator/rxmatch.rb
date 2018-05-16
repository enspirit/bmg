module Bmg
  module Operator
    #
    # Rxmatch operator.
    #
    # Filters operand's tuples to those whose attributes match a
    # given string or regular expression.
    #
    class Rxmatch
      include Operator::Unary

      DEFAULT_OPTIONS = {
        case_sensitive: false
      }

      def initialize(type, operand, attrs, matcher, options)
        @type = type
        @operand = operand
        @attrs = attrs
        @matcher = matcher
        @options = DEFAULT_OPTIONS.merge(options)
      end

    protected

      attr_reader :attrs, :matcher, :options

      def case_sensitive?
        !!options[:case_sensitive]
      end

    public

      def each
        @operand.each do |tuple|
          against = attrs.map{|a| tuple[a] }.join(" ")
          matcher = self.matcher
          unless case_sensitive?
            against = against.downcase
            matcher = matcher.downcase if matcher.is_a?(String)
          end
          yield(tuple) if against.match(matcher)
        end
      end

      def to_ast
        [ :rxmatch, operand.to_ast, attrs.dup, matcher, options.dup ]
      end

    protected

      def _restrict(type, predicate)
        @operand
          .restrict(predicate)
          .rxmatch(attrs, matcher, options)
      end

    protected ### inspect

      def args
        [ attrs, matcher, options ]
      end

    end # class Rxmatch
  end # module Operator
end # module Bmg

module Bmg
  module Operator
    #
    # Minus operator.
    #
    # Returns all tuples which are in the left operand but not in the right
    # operand.
    #
    # This implementation is actually a NAry-Minus, since it handles
    # an arbitrary number of operands.
    #
    class Minus
      include Operator::Nary

      def initialize(type, operands)
        @type = type
        @operands = operands
      end

    public

      def each(&bl)
        return to_enum unless block_given?
        initial = operands[0].to_set
        tuples = operands.drop(1).inject(initial) do |agg, op|
          agg - op.to_set
        end
        tuples.each(&bl)
      end

      def to_ast
        [ :minus ] + operands.map(&:to_ast)
      end

    protected ### optimization

      def _minus(type, other)
        return self if other.is_a?(Relation::Empty)
        case other
        when Minus
          Minus.new(type, operands + other.operands)
        else
          Minus.new(type, operands + [other])
        end
      end

    end # class Union
  end # module Operator
end # module Bmg

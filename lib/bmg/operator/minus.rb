module Bmg
  module Operator
    #
    # Minus operator.
    #
    # Returns all tuples which are in the left operand but not 
    # in the right operand.
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
        initial = operands[0].to_a
        tuples = operands.drop(1).inject(initial) do |agg, op|
          agg - op.to_a
        end
        tuples.each(&bl)
      end

      def to_ast
        [ :minus ] + operands.map(&:to_ast)
      end

    end # class Union
  end # module Operator
end # module Bmg

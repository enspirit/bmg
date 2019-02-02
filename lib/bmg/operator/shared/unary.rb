module Bmg
  module Operator
    module Unary
      include Operator

    protected

      attr_reader :operand

      def _visit(parent, visitor)
        visitor.call(self, parent)
        operand._visit(self, visitor)
      end

      def operands
        [operand]
      end

    end # module Unary
  end # module Operator
end # module Bmg

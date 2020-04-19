module Bmg
  module Operator
    module Unary
      include Operator

      def bind(binding)
        _with_operand(operand.bind(binding))
      end

    protected

      attr_accessor :operand

      def _visit(parent, visitor)
        visitor.call(self, parent)
        operand._visit(self, visitor)
      end

      def _with_operand(operand)
        dup.tap{|d| d.operand = operand }
      end

      def operands
        [operand]
      end

    end # module Unary
  end # module Operator
end # module Bmg

module Bmg
  module Operator
    module Zeroary
      include Operator

      def bind(binding)
        dup
      end

    protected

      attr_accessor :operand

      def _visit(parent, visitor)
        visitor.call(self, parent)
      end

      def operands
        []
      end

    end # module Zeroary
  end # module Operator
end # module Bmg

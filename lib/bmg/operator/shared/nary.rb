module Bmg
  module Operator
    module Nary
      include Operator

      def bind(binding)
        _with_operands(operands.map{|op| op.bind(binding) })
      end

    protected

      attr_accessor :operands

      def _with_operands(operands)
        dup.tap{|d| d.operands = operands }
      end

      def _visit(parent, visitor)
        visitor.call(self, parent)
        operands.each{|op|
          op.send(:_visit, self, visitor)
        }
      end

    end # module Nary
  end # module Operator
end # module Bmg

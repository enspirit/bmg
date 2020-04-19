module Bmg
  module Operator
    module Binary
      include Operator

      def bind(binding)
        _with_operands(left.bind(binding), right.bind(binding))
      end

    protected

      attr_accessor :left, :right

      def _visit(parent, visitor)
        visitor.call(self, parent)
        left.send(:_visit, self, visitor)
        right.send(:_visit, self, visitor)
      end

      def _with_operands(left, right)
        dup.tap{|d|
          d.left = left
          d.right = right
        }
      end

      def operands
        [left, right]
      end

    end # module Binary
  end # module Operator
end # module Bmg

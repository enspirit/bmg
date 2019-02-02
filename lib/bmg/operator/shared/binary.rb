module Bmg
  module Operator
    module Binary
      include Operator

    protected

      attr_reader :left, :right

      def _visit(parent, visitor)
        visitor.call(self, parent)
        left.send(:_visit, self, visitor)
        right.send(:_visit, self, visitor)
      end

      def operands
        [left, right]
      end

    end # module Binary
  end # module Operator
end # module Bmg

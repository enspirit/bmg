module Bmg
  module Operator
    module Nary
      include Operator

    protected

      attr_reader :operands

      def _visit(parent, visitor)
        visitor.call(self, parent)
        operands.each{|op|
          op.send(:_visit, self, visitor)
        }
      end

    end # module Nary
  end # module Operator
end # module Bmg

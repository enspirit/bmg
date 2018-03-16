module Bmg
  module Operator
    include Relation

    module Unary
      include Operator

      attr_reader :type, :operand

      def _visit(parent, visitor)
        visitor.call(self, parent)
        operand._visit(self, visitor)
      end
    end

    module Binary
      include Operator

      attr_reader :type, :left, :right

      def _visit(parent, visitor)
        visitor.call(self, parent)
        left._visit(self, visitor)
        right._visit(self, visitor)
      end
    end

    module Nary
      include Operator

      attr_reader :type, :operands

      def _visit(parent, visitor)
        visitor.call(self, parent)
        operands.each{|op| op._visit(self, visitor) }
      end
    end

  end
end
require_relative 'operator/allbut'
require_relative 'operator/autosummarize'
require_relative 'operator/autowrap'
require_relative 'operator/constants'
require_relative 'operator/extend'
require_relative 'operator/image'
require_relative 'operator/project'
require_relative 'operator/rename'
require_relative 'operator/restrict'
require_relative 'operator/union'

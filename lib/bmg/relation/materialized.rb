module Bmg
  module Relation
    class Materialized
      include Operator::Unary

      def initialize(operand)
        @operand = operand
      end

      def type
        operand.type
      end

      def type=(type)
        operand.type = type
      end
      protected :type=

    public

      def each(&bl)
        @operand = Relation::InMemory.new(operand.type, operand.to_a) unless @operand.is_a?(Relation::InMemory)
        @operand.each(&bl)
      end

      def to_ast
        [ :materizalized, operand ]
      end

      def args
        []
      end

    end # class Materialized
  end # module Relation
end # module Bmg

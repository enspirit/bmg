module Bmg
  module Relation
    class Materialized
      include Operator::Unary

      def initialize(operand)
        @operand = operand
        @materialized = nil
      end

      def type
        operand.type
      end

      def type=(type)
        operand.type = type
      end
      protected :type=

    public

      def _count
        _materialize._count
      end

    public

      def each(&bl)
        return to_enum unless block_given?
        _materialize.each(&bl)
      end

      def to_ast
        [ :materizalized, operand ]
      end

      def args
        []
      end

    private

      def _materialize
        return @materialized if @materialized

        @materialized = Relation::InMemory.new(operand.type, operand.to_a)
      end

    end # class Materialized
  end # module Relation
end # module Bmg

module Bmg
  module Relation
    class InMemory
      include Relation

      def initialize(type, operand)
        @operand = operand
        @type = type
      end
      attr_reader :type, :operand

    public

      def each(&bl)
        @operand.each(&bl)
      end

      def to_ast
        [ :in_memory, operand ]
      end

    end # class InMemory
  end # module Relation
end # module Bmg

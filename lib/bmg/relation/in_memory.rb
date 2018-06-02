module Bmg
  module Relation
    class InMemory
      include Relation

      def initialize(type, operand)
        @operand = operand
        @type = type
      end
      attr_accessor :type
      protected :type=
      attr_reader :operand

    public

      def each(&bl)
        @operand.each(&bl)
      end

      def to_ast
        [ :in_memory, operand ]
      end

      def to_s
        "(in_memory ...)"
      end

      def inspect
        "(in_memory #{operand.inspect})"
      end

    end # class InMemory
  end # module Relation
end # module Bmg

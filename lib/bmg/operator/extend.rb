module Bmg
  module Operator
    #
    # Extend operator.
    #
    # Extends operand's tuples with attributes
    # resulting from given computations
    #
    # Example:
    #
    #   [{ a: 1 }] extend { b: ->(t){ 2 } } => [{ a: 1, b: 2 }]
    #
    class Extend
      include Operator

      def initialize(operand, extension)
        @operand = operand
        @extension = extension
      end

      def each
        @operand.each do |tuple|
          yield extend_it(tuple)
        end
      end

    private

      def extend_it(tuple)
        @extension.each_with_object(tuple.dup) { |(k,v), memo|
          memo[k] = v.call(tuple)
          memo
        }
      end

    end # class Extend
  end # module Operator
end # module Bmg

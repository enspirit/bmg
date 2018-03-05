module Bmg
  module Operator
    #
    # Restrict operator.
    #
    # Filters operand's tuples to those that meet the predicate received
    # at construction.
    #
    class Restrict
      include Operator

      def initialize(operand, predicate)
        @operand = operand
        @predicate = predicate
      end

      def each
        @operand.each do |tuple|
          yield(tuple) if @predicate.evaluate(tuple)
        end
      end

    end # class Restrict
  end # module Operator
end # module Bmg

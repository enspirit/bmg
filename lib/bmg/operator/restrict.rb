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

    private

      attr_reader :operand,  :predicate

    public

      def each
        @operand.each do |tuple|
          yield(tuple) if @predicate.evaluate(tuple)
        end
      end

      def restrict(predicate)
        Restrict.new(@operand, @predicate & predicate)
      end

    end # class Restrict
  end # module Operator
end # module Bmg

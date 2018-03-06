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

      def initialize(type, operand, predicate)
        @type = type
        @operand = operand
        @predicate = predicate
      end
      attr_reader :type

    protected

      attr_reader :operand, :predicate

    public

      def each
        @operand.each do |tuple|
          yield(tuple) if @predicate.evaluate(tuple)
        end
      end

    protected

      def _restrict(type, predicate)
        Restrict.new(type, @operand, @predicate & predicate)
      end

    end # class Restrict
  end # module Operator
end # module Bmg

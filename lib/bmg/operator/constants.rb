module Bmg
  module Operator
    #
    # Constants operator.
    #
    # Extends operand's tuples with attributes given at construction.
    # This is a special case of an extension, where the values are
    # statically known.
    #
    class Constants
      include Operator

      def initialize(type, operand, cs)
        @type = type
        @operand = operand
        @cs = cs
      end
      attr_reader :type

    protected

      attr_reader :operand, :cs

    public

      def each
        @operand.each do |tuple|
          yield extend_it(tuple)
        end
      end

    private

      def extend_it(tuple)
        tuple.merge(@cs)
      end

    end # class Constants
  end # module Operator
end # module Bmg

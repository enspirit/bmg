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

      def initialize(type, operand, constants)
        @type = type
        @operand = operand
        @constants = constants
      end
      attr_reader :type

    protected

      attr_reader :operand, :constants

    public

      def each
        @operand.each do |tuple|
          yield extend_it(tuple)
        end
      end

    public ### optimization

      def restrict(predicate)
        predicate = Predicate.coerce(predicate)
        type = self.type.restrict(predicate)
        top_p, bottom_p = predicate.and_split(constants.keys)
        if top_p == predicate
          super
        else
          result = operand
          result = result.restrict(bottom_p) unless bottom_p.tautology?
          result = result.constants(constants)
          result = result.restrict(top_p) unless top_p.tautology?
          result
        end
      rescue Predicate::NotSupportedError
        super
      end

    private

      def extend_it(tuple)
        tuple.merge(@constants)
      end

    end # class Constants
  end # module Operator
end # module Bmg

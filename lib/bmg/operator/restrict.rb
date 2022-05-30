module Bmg
  module Operator
    #
    # Restrict operator.
    #
    # Filters operand's tuples to those that meet the predicate received
    # at construction.
    #
    class Restrict
      include Operator::Unary

      def initialize(type, operand, predicate)
        @type = type
        @operand = operand
        @predicate = predicate
      end

    protected

      attr_reader :predicate

    public

      def bind(binding)
        Restrict.new(type, operand.bind(binding), predicate.bind(binding))
      end

      def each
        return to_enum unless block_given?
        @operand.each do |tuple|
          yield(tuple) if @predicate.evaluate(tuple)
        end
      end

      def insert(tuple)
        operand.insert(tuple)
      end

      def update(updating, predicate = Predicate.tautology)
        operand.update(updating, predicate & self.predicate)
      end

      def delete(predicate = Predicate.tautology)
        operand.delete(predicate & self.predicate)
      end

      def to_ast
        [ :restrict, operand.to_ast, predicate.sexpr ]
      end

    protected

      def _restrict(type, predicate)
        Restrict.new(type, @operand, @predicate & predicate)
      end

    protected ### inspect

      def args
        [ predicate ]
      end

    end # class Restrict
  end # module Operator
end # module Bmg

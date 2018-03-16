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
      include Operator::Unary

      def initialize(type, operand, extension)
        @type = type
        @operand = operand
        @extension = extension
      end

    protected

      attr_reader :extension

    public

      def each
        @operand.each do |tuple|
          yield extend_it(tuple)
        end
      end

      def insert(arg)
        case arg
        when Hash       then operand.insert(allbut_extkeys(arg))
        when Relation   then operand.insert(arg.allbut(extension.keys))
        when Enumerable then operand.insert(arg.map{|t| allbut_extkeys(t) })
        else
          super
        end
      end

      def update(tuple)
        operand.update(allbut_extkeys(tuple))
      end

      def delete
        operand.delete
      end

      def to_ast
        [ :extend, operand.to_ast, extension.dup ]
      end

    protected ### optimization

      def _restrict(type, predicate)
        top, bottom = predicate.and_split(extension.keys)
        if top == predicate
          super
        else
          op = operand
          op = op.restrict(bottom)
          op = op.extend(extension)
          op = op.restrict(top)
          op
        end
      end

    protected ### inspect

      def args
        [ extension ]
      end

    private

      def extend_it(tuple)
        @extension.each_with_object(tuple.dup) { |(k,v), memo|
          memo[k] = v.call(tuple)
          memo
        }
      end

      def allbut_extkeys(tuple)
        TupleAlgebra.allbut(tuple, extension.keys)
      end

    end # class Extend
  end # module Operator
end # module Bmg

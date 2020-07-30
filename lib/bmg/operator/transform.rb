module Bmg
  module Operator
    #
    # Transform operator.
    #
    # Transforms existing attributes through computations
    #
    # Example:
    #
    #   [{ a: 1 }] transform { a: ->(t){ t[:a]*2 } } => [{ a: 4 }]
    #
    class Transform
      include Operator::Unary

      DEFAULT_OPTIONS = {}

      def initialize(type, operand, transformation, options = {})
        @type = type
        @operand = operand
        @transformation = transformation
        @options = DEFAULT_OPTIONS.merge(options)
      end

    protected

      attr_reader :transformation

    public

      def each
        t = transformer
        @operand.each do |tuple|
          yield t.call(tuple)
        end
      end

      def to_ast
        [ :transform, operand.to_ast, transformation.dup ]
      end

    protected ### optimization

    protected ### inspect

      def args
        [ transformation ]
      end

    private

      def transformer
        @transformer ||= TupleTransformer.new(transformation)
      end

    end # class Transform
  end # module Operator
end # module Bmg

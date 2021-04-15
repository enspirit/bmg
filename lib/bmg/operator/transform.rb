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

      attr_reader :transformation, :options

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

      def _allbut(type, butlist)
        # `allbut` can always be pushed down the tree. unlike
        # `extend` the Proc that might be used cannot use attributes
        # in butlist, so it's safe to strip them away.
        if transformer.knows_attrlist?
          # We just need to clean the transformation
          attrlist = transformer.to_attrlist
          thrown = attrlist & butlist
          t = transformation.dup.reject{|k,v| thrown.include?(k) }
          operand.allbut(butlist).transform(t, options)
        else
          operand.allbut(butlist).transform(transformation, options)
        end
      end

      def _project(type, attrlist)
        if transformer.knows_attrlist?
          t = transformation.dup.select{|k,v| attrlist.include?(k) }
          operand.project(attrlist).transform(t, options)
        else
          operand.project(attrlist).transform(transformation, options)
        end
      end

      def _restrict(type, predicate)
        return super unless transformer.knows_attrlist?
        top, bottom = predicate.and_split(transformer.to_attrlist)
        if top == predicate
          super
        else
          operand
            .restrict(bottom)
            .transform(transformation, options)
            .restrict(top)
        end
      end

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

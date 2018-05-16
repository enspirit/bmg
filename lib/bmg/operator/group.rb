module Bmg
  module Operator
    #
    # Group operator.
    #
    # Groups some operand attributes as a new Relation-valued
    # attribute
    #
    class Group
      include Operator::Unary

      DEFAULT_OPTIONS = {

        # Whether we need to convert each group as an Array,
        # instead of keeping a Relation instance
        array: false

      }

      def initialize(type, operand, attrs, as, options)
        @type = type
        @operand = operand
        @attrs = attrs
        @as = as
        @options = DEFAULT_OPTIONS.merge(options)
      end

    protected

      attr_reader :attrs, :as, :options

    public

      def each(&bl)
        index = Hash.new{|h,k| h[k] = k.merge(as => empty_group) }
        operand.each do |tuple|
          key = TupleAlgebra.allbut(tuple, attrs)
          sub = TupleAlgebra.project(tuple, attrs)
          index[key][as].operand << sub
        end
        if options[:array]
          index.values.each do |tuple|
            tuple[as] = tuple[as].to_a
            yield(tuple)
          end
        else
          index.values.each(&bl)
        end
      end

      def to_ast
        [ :group, operand.to_ast, attrs.dup, as, options.dup ]
      end

    protected ### optimization

      def _restrict(type, predicate)
        top, bottom = predicate.and_split([as])
        if top == predicate
          super
        else
          op = operand
          op = op.restrict(bottom)
          op = op.group(attrs, as, options)
          op = op.restrict(top)
          op
        end
      end

    protected ### inspect

      def args
        [ attrs, as, options ]
      end

    private

      def empty_group
        Relation::InMemory.new(group_type, Set.new)
      end

      def group_type
        type.project(attrs)
      end

    end # class Extend
  end # module Operator
end # module Bmg

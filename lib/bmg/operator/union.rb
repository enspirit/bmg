module Bmg
  module Operator
    #
    # Union operator.
    #
    # Returns all tuples of the left operand followed by all
    # tuples from the right operand.
    #
    # This implementation is actually a NAry-Union, since it handles
    # an arbitrary number of operands.
    #
    # By default, this operator strips duplicates, as of relational
    # theory. Please set the `:all` option to true to avoid this
    # behavior and save execution time.
    #
    class Union
      include Operator::Nary

      DEFAULT_OPTIONS = {
        all: false
      }

      def initialize(type, operands, options = {})
        @type = type
        @operands = operands
        @options = DEFAULT_OPTIONS.merge(options)
      end

    protected

      attr_reader :options

    public

      def all?
        @options[:all]
      end

      def each(&bl)
        if all?
          operands.each do |op|
            op.each(&bl)
          end
        else
          seen = {}
          operands.each do |op|
            op.each do |tuple|
              yield(tuple) unless seen.has_key?(tuple)
              seen[tuple] = true
            end
          end
        end
      end

      def to_ast
        [ :union ] + operands.map(&:to_ast) + [ options.dup ]
      end

    protected ### optimization

      def _restrict(type, predicate)
        ops = operands
          .map   {|op| op.restrict(predicate)    }
          .reject{|op| op.is_a?(Relation::Empty) }
        case ops.size
        when 0 then Relation.empty(type)
        when 1 then ops.first
        else Union.new(type, ops, options)
        end
      end

      def _union(type, other, options)
        return self if other.is_a?(Relation::Empty)
        norm_options = DEFAULT_OPTIONS.merge(options)
        return super unless norm_options == self.options
        case other
        when Union
          return super unless norm_options == other.send(:options)
          Union.new(type, operands + other.operands, options)
        else
          Union.new(type, operands + [other], options)
        end
      end

    protected ### inspect

      def args
        [ options ]
      end

    end # class Union
  end # module Operator
end # module Bmg

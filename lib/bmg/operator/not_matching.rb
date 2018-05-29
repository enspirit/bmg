module Bmg
  module Operator
    #
    # NotMatching operator.
    #
    # Filters tuples of left operand to those matching no tuple
    # in right operand.
    #
    class NotMatching
      include Operator::Binary

      def initialize(type, left, right, on)
        @type = type
        @left = left
        @right = right
        @on = on
      end

    private

      attr_reader :on

    public

      def each
        index = Hash.new
        right.each_with_object(index) do |t, index|
          key = tuple_project(t, on)
          index[key] = true
        end
        left.each do |tuple|
          key = tuple_project(tuple, on)
          yield tuple unless index.has_key?(key)
        end
      end

      def to_ast
        [ :not_matching, left.to_ast, right.to_ast, on ]
      end

    protected ### optimization

      def _restrict(type, predicate)
        # Predicate can always be fully applied to left
        # It can never be applied on right, unlike matching
        left
          .restrict(predicate)
          .not_matching(right, on)
      end

    protected ### inspect

      def args
        [ on ]
      end

    private

      def tuple_project(tuple, on)
        TupleAlgebra.project(tuple, on)
      end

    end # class NotMatching
  end # module Operator
end # module Bmg

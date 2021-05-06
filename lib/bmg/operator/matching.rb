module Bmg
  module Operator
    #
    # Matching operator.
    #
    # Filters tuples of left operand to those matching at least
    # one tuple in right operand.
    #
    class Matching
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
        return to_enum unless block_given?
        index = Hash.new
        right.each_with_object(index) do |t, index|
          key = tuple_project(t, on)
          index[key] = true
        end
        left.each do |tuple|
          key = tuple_project(tuple, on)
          yield tuple if index.has_key?(key)
        end
      end

      def to_ast
        [ :matching, left.to_ast, right.to_ast, on ]
      end

    protected ### optimization

      def _restrict(type, predicate)
        # Predicate can always be fully applied to left
        new_left = left.restrict(predicate)

        # regarding right... the predicate possibly makes references
        # to the join key, but also to left attributes... let split
        # on the join key attributes, to try to remove spurious
        # attributes for right...
        on_on_and_more, left_only = predicate.and_split(on)

        # it's not guaranteed! let now check whether the split led
        # to a situation where the predicate on `on` attributes
        # actually refers to no other ones...
        if !on_on_and_more.tautology? and (on_on_and_more.free_variables - on).empty?
          new_right = right.restrict(on_on_and_more)
        else
          new_right = right
        end

        new_left.matching(new_right, on)
      rescue Predicate::NotSupportedError
        super
      end

    protected ### inspect

      def args
        [ on ]
      end

    private

      def tuple_project(tuple, on)
        TupleAlgebra.project(tuple, on)
      end

    end # class Matching
  end # module Operator
end # module Bmg

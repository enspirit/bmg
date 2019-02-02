module Bmg
  module Operator
    #
    # Join operator.
    #
    # Natural join, following relational algebra
    #
    class Join
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
          index[key] ||= []
          index[key] << t
        end
        left.each do |tuple|
          key = tuple_project(tuple, on)
          if to_join = index[key]
            to_join.each do |right|
              yield right.merge(tuple)
            end
          end
        end
      end

      def to_ast
        [ :join, left.to_ast, right.to_ast, on ]
      end

    protected ### optimization

      def _autowrap(type, options)
        u_left,  left_replaced  = _unautowrap(left, options)
        u_right, right_replaced = _unautowrap(right, options)
        if (!left_replaced && !right_replaced)
          super
        else
          u_left.join(u_right, on).autowrap(options)
        end
      end

      def _unautowrap(operand, options)
        return [operand, false] unless operand.is_a?(Operator::Autowrap)
        return [operand, false] unless operand.same_options?(options)
        [operand.send(:operand), true]
      end
      private :_unautowrap

    protected ### inspect

      def args
        [ on ]
      end

    private

      def tuple_project(tuple, on)
        TupleAlgebra.project(tuple, on)
      end

    end # class Join
  end # module Operator
end # module Bmg

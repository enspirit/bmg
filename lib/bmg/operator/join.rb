module Bmg
  module Operator
    #
    # Join operator.
    #
    # Natural join, following relational algebra
    #
    class Join
      include Operator::Binary

      DEFAULT_OPTIONS = {}

      def initialize(type, left, right, on, options = {})
        @type = type
        @left = left
        @right = right
        @on = on
        @options = DEFAULT_OPTIONS.merge(options)
      end

    private

      attr_reader :on, :options

    public

      def each
        return to_enum unless block_given?
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
          elsif left_join?
            yield(tuple.merge(default_right_tuple))
          end
        end
      end

      def to_ast
        [ :join, left.to_ast, right.to_ast, on, extra_opts ].compact
      end

    protected

      def left_join?
        options[:variant] == :left
      end

      def default_right_tuple
        options[:default_right_tuple]
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

      def extra_opts
        extra = options.dup.delete_if{|k,v| DEFAULT_OPTIONS[k] == v }
        extra.empty? ? nil : extra
      end

      def args
        [ on, extra_opts ].compact
      end

    private

      def tuple_project(tuple, on)
        TupleAlgebra.project(tuple, on)
      end

    end # class Join
  end # module Operator
end # module Bmg

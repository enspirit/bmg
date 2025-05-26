module Bmg
  module Operator
    #
    # Undress operator.
    #
    # Transform all values to keep only integer, strings & booleans
    #
    class Undress
      include Operator::Unary

      DEFAULT_OPTIONS = {}

      def initialize(type, operand, options = {})
        @type = type
        @operand = operand
        @options = DEFAULT_OPTIONS.merge(options)
      end

    protected

      attr_reader :options

    public

      def each
        return to_enum unless block_given?

        @operand.each do |tuple|
          yield undress(tuple)
        end
      end

      def to_ast
        [ :transform, operand.to_ast, transformation.dup ]
      end

    protected ### inspect

      def args
        [ ]
      end

    private

      def undress(value)
        case value
        when ->(v) { v.respond_to?(:undress) }
          value.undress
        when Hash
          value.each_with_object({}) do |(k,v), undressed|
            undressed[k] = undress(v)
          end
        when Relation
          Relation.new value.map{|tuple| undress(tuple) }
        when Date, Time
          value.iso8601
        when Array
          value.map{|v| undress(v) }
        else
          value
        end
      end

    end # class Undress
  end # module Operator
end # module Bmg

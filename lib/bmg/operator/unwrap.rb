module Bmg
  module Operator
    class Unwrap
      include Operator::Unary

      def initialize(type, operand, attrs)
        @type = type
        @operand = operand
        @attrs = attrs
      end

    protected

      attr_reader :attrs

    public

      def each(&bl)
        return to_enum unless block_given?
        operand.each do |tuple|
          yield tuple_unwrap(tuple)
        end
      end

      def to_ast
        [ :unwrap, operand.to_ast, attrs ]
      end

    protected

      def tuple_unwrap(tuple)
        attrs.inject(tuple.dup){|t,attr|
          t.merge(tuple[attr]).tap{|t2|
            t2.delete(attr)
          }
        }
      end

    protected ### inspect

      def args
        [ attrs ]
      end

    end # class Unwrap
  end # module Operator
end # module Bmg

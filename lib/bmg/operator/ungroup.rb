module Bmg
  module Operator
    class Ungroup
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
        if type.knows_keys? && type.keys.any?{|k| (k & attrs).empty? }
          operand.each do |tuple|
            _each(tuple, attrs[0], attrs[1..-1], &bl)
          end
        else
          with_dups = []
          operand.each do |tuple|
            _each(tuple, attrs[0], attrs[1..-1]){|t|
              with_dups << t
            }
          end
          with_dups.uniq.each(&bl)
        end
      end

      def _each(tuple, attr, attrs, &bl)
        rva = tuple[attr] || []
        rva.each do |rvt|
          t = tuple.merge(rvt).tap{|t| t.delete(attr) }
          if attrs.empty?
            yield(t)
          else
            _each(t, attrs[0], attrs[1..-1], &bl)
          end
        end
      end

      def to_ast
        [ :ungroup, operand.to_ast, attrs ]
      end

    protected

    protected ### inspect

      def args
        [ attrs ]
      end

    end # class Ungroup
  end # module Operator
end # module Bmg

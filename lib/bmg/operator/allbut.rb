module Bmg
  module Operator
    #
    # Allbut operator.
    #
    # Projects operand's tuples on all but given attributes, that is,
    # removes attributes in the list. The operator takes care of removing
    # duplicates.
    #
    # Example:
    #
    #   [{ a: 1, b: 2 }] allbut [:b] => [{ a: 1 }]
    #
    # All attributes in the butlist SHOULD be existing attributes of the
    # input tuples.
    #
    class Allbut
      include Operator::Unary

      def initialize(type, operand, butlist)
        @type = type
        @operand = operand
        @butlist = butlist
      end

    protected

      attr_reader :butlist

    public

      def each
        seen = {}
        @operand.each do |tuple|
          allbuted = tuple_allbut(tuple)
          unless seen.has_key?(allbuted)
            yield(allbuted)
            seen[allbuted] = true
          end
        end
      end

      def insert(arg)
        case arg
        when Hash       then operand.insert(valid_tuple!(arg))
        when Enumerable then operand.insert(arg.map{|t| valid_tuple!(t) })
        else
          super
        end
      end

      def update(tuple)
        operand.update(valid_tuple!(tuple))
      end

      def delete
        operand.delete
      end

      def to_ast
        [:allbut, operand.to_ast, butlist.dup]
      end

    protected ### optimization

      def _restrict(type, predicate)
        operand.restrict(predicate).allbut(butlist)
      end

    private

      def tuple_allbut(tuple)
        TupleAlgebra.allbut(tuple, @butlist)
      end

      def valid_tuple!(tuple)
        offending = tuple.keys & butlist
        raise InvalidUpdateError, "#{offending.inspect} cannot be updated" unless offending.empty?
        tuple
      end

    end # class Allbut
  end # module Operator
end # module Bmg

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
      include Operator

      def initialize(type, operand, butlist)
        @type = type
        @operand = operand
        @butlist = butlist
      end

    protected

      attr_reader :type, :operand, :butlist

    public

      def each
        seen = {}
        @operand.each do |tuple|
          allbuted = allbut(tuple)
          unless seen.has_key?(allbuted)
            yield(allbuted)
            seen[allbuted] = true
          end
        end
      end

    private

      def allbut(tuple)
        tuple.delete_if{|k,_| @butlist.include?(k) }
      end

    end # class Allbut
  end # module Operator
end # module Bmg

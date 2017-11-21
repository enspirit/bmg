module Bmg
  module Operator
    #
    # Project operator.
    #
    # Projects operand's tuples on given attributes, that is, keep those attributes
    # only. The operator takes care of removing duplicates.
    #
    # Example:
    #
    #   [{ a: 1, b: 2 }] project [:b] => [{ b: 2 }]
    #
    # All attributes in the attrlist SHOULD be existing attributes of the
    # input tuples.
    #
    class Project
      include Operator

      def initialize(operand, attrlist)
        @operand = operand
        @attrlist = attrlist
      end

      def each
        seen = {}
        @operand.each do |tuple|
          projected = project(tuple)
          unless seen.has_key?(projected)
            yield(projected)
            seen[projected] = true
          end
        end
      end

    private

      def project(tuple)
        tuple.delete_if{|k,_| !@attrlist.include?(k) }
      end

    end # class Project
  end # module Operator
end # module Bmg

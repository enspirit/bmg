module Bmg
  module Operator
    #
    # Rename operator.
    #
    # Rename some attribute of input tuples, according to a renaming Hash.
    #
    # Example:
    #
    #   [{ a: 1, b: 2 }] rename {:b => :c} => [{ a: 1, c: 2 }]
    #
    # Keys of the renaming Hash SHOULD be existing attributes of the
    # input tuples. Values of the renaming Hash SHOULD NOT be existing
    # attributes of the input tuples.
    #
    class Rename
      include Operator

      def initialize(operand, renaming)
        @operand = operand
        @renaming = renaming
      end

      def each
        @operand.each do |tuple|
          yield rename(tuple)
        end
      end

    private

      def rename(tuple)
        tuple.each_with_object({}){|(k,v),h|
          h[rename_key(k)] = v
          h
        }
      end

      def rename_key(k)
        @renaming[k] || k
      end

    end # class Rename
  end # module Operator
end # module Bmg

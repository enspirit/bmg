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

      def initialize(type, operand, renaming)
        @type = type
        @operand = operand
        @renaming = renaming
      end
      attr_reader :type

    private

      attr_reader :operand, :renaming

    public

      def each
        @operand.each do |tuple|
          yield rename(tuple)
        end
      end

      def to_ast
        [ :rename, operand.to_ast, renaming.dup ]
      end

    protected ### optimization

      def _restrict(type, predicate)
        reversed = reverse_renaming(renaming)
        operand.restrict(predicate.rename(reversed)).rename(renaming)
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

      def reverse_renaming(renaming)
        renaming.each_with_object({}){|(k,v),h| h[v] = k }
      end

    end # class Rename
  end # module Operator
end # module Bmg

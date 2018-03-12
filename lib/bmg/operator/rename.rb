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
          yield rename(tuple, renaming)
        end
      end

      def insert(arg)
        case arg
        when Hash       then operand.insert(rename(arg, reverse_renaming))
        when Relation   then operand.insert(arg.rename(reverse_renaming))
        when Enumerable then operand.insert(arg.map{|t| rename(t, reverse_renaming) })
        else
          super
        end
      end

      def update(arg)
        case arg
        when Hash then operand.update(rename(arg, reverse_renaming))
        else
          super
        end
      end

      def delete
        operand.delete
      end

      def to_ast
        [ :rename, operand.to_ast, renaming.dup ]
      end

    protected ### optimization

      def _restrict(type, predicate)
        operand.restrict(predicate.rename(reverse_renaming)).rename(renaming)
      end

    private

      def rename(tuple, renaming)
        tuple.each_with_object({}){|(k,v),h|
          h[renaming[k] || k] = v
          h
        }
      end

      def reverse_renaming
        renaming.each_with_object({}){|(k,v),h| h[v] = k }
      end

    end # class Rename
  end # module Operator
end # module Bmg

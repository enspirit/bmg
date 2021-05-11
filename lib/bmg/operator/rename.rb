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
      include Operator::Unary

      def initialize(type, operand, renaming)
        @type = type
        @operand = operand
        @renaming = renaming
      end

    private

      attr_reader :renaming

    public

      def each
        return to_enum unless block_given?
        @operand.each do |tuple|
          yield rename_tuple(tuple, renaming)
        end
      end

      def insert(arg)
        case arg
        when Hash       then operand.insert(rename_tuple(arg, reverse_renaming))
        when Relation   then operand.insert(arg.rename(reverse_renaming))
        when Enumerable then operand.insert(arg.map{|t| rename_tuple(t, reverse_renaming) })
        else
          super
        end
      end

      def update(arg)
        case arg
        when Hash then operand.update(rename_tuple(arg, reverse_renaming))
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

    public ### for internal reasons

      def _count
        operand._count
      end

    protected ### optimization

      def _page(type, ordering, page_index, options)
        rr = reverse_renaming
        ordering = ordering.map{|(k,v)|
          v.nil? ? rr[k] || k : [rr[k] || k, v]
        }
        operand.page(ordering, page_index, options).rename(renaming)
      end

      def _restrict(type, predicate)
        operand.restrict(predicate.rename(reverse_renaming)).rename(renaming)
      end

    protected ### inspect

      def args
        [ renaming ]
      end

    private

      def rename_tuple(tuple, renaming)
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

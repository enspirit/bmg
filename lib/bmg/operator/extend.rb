module Bmg
  module Operator
    #
    # Extend operator.
    #
    # Extends operand's tuples with attributes
    # resulting from given computations
    #
    # Example:
    #
    #   [{ a: 1 }] extend { b: ->(t){ 2 } } => [{ a: 1, b: 2 }]
    #
    class Extend
      include Operator::Unary

      def initialize(type, operand, extension)
        @type = type
        @operand = operand
        @extension = extension
      end

    protected

      attr_reader :extension

    public

      def each
        return to_enum unless block_given?
        @operand.each do |tuple|
          yield extend_it(tuple)
        end
      end

      def insert(arg)
        case arg
        when Hash       then operand.insert(allbut_extkeys(arg))
        when Relation   then operand.insert(arg.allbut(extension.keys))
        when Enumerable then operand.insert(arg.map{|t| allbut_extkeys(t) })
        else
          super
        end
      end

      def update(tuple)
        operand.update(allbut_extkeys(tuple))
      end

      def delete
        operand.delete
      end

      def to_ast
        [ :extend, operand.to_ast, extension.dup ]
      end

    public ### for internal reasons

      def _count
        operand._count
      end

    protected ### optimization

      def _allbut(type, butlist)
        ext_keys = extension.keys
        if (ext_keys & butlist).empty?
          # extension not touched, fully kept
          # as it might use butlist attributes, we can't push anything down
          super
        else
          # extension partly stripped away, simplify them
          new_ext = TupleAlgebra.allbut(extension, butlist)
          new_but = butlist - ext_keys
          operand.extend(new_ext).allbut(new_but)
        end
      end

      def _join(type, right, on)
        ext_keys = extension.keys
        if (ext_keys & on).empty?
          operand.join(right, on).extend(extension)
        else
          super
        end
      end

      def _matching(type, right, on = [])
        ext_keys = extension.keys
        if (ext_keys & on).empty?
          operand.matching(right, on).extend(extension)
        else
          super
        end
      end

      def _not_matching(type, right, on = [])
        ext_keys = extension.keys
        if (ext_keys & on).empty?
          operand.not_matching(right, on).extend(extension)
        else
          super
        end
      end

      def _rename(type, renaming)
        shared = renaming.keys & extension.keys
        new_ext = TupleAlgebra.rename(extension, renaming)
        new_ren = TupleAlgebra.allbut(renaming, shared)
        operand.rename(new_ren).extend(new_ext)
      end

      def _restrict(type, predicate)
        top, bottom = predicate.and_split(extension.keys)
        if top == predicate
          super
        else
          op = operand
          op = op.restrict(bottom)
          op = op.extend(extension)
          op = op.restrict(top)
          op
        end
      end

      def _page(type, ordering, page_index, opts)
        attrs = ordering.map{|(a,d)| a }
        if (attrs & @extension.keys).empty?
          op = operand
          op = op.page(ordering, page_index, opts)
          op = op.extend(extension)
          op
        else
          super
        end
      end

      def _project(type, attrlist)
        ext_keys = extension.keys
        if (ext_keys - attrlist).empty?
          # extension fully kept, no optimization
          # (we can't push anything down, because the extension itself might
          # use all attributes)
          super
        else
          # extension partly or fully stripped away, simplify it
          new_ext = TupleAlgebra.project(extension, attrlist)
          operand.extend(new_ext).project(attrlist)
        end
      end


    protected ### inspect

      def args
        [ extension ]
      end

    private

      def extend_it(tuple)
        @extension.each_with_object(tuple.dup) { |(k,v), memo|
          memo[k] = v.call(tuple)
          memo
        }
      end

      def allbut_extkeys(tuple)
        TupleAlgebra.allbut(tuple, extension.keys)
      end

    end # class Extend
  end # module Operator
end # module Bmg

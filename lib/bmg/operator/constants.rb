module Bmg
  module Operator
    #
    # Constants operator.
    #
    # Extends operand's tuples with attributes given at construction.
    # This is a special case of an extension, where the values are
    # statically known.
    #
    class Constants
      include Operator::Unary

      def initialize(type, operand, the_constants)
        @type = type
        @operand = operand
        @the_constants = the_constants
      end

    protected

      attr_reader :the_constants

    public

      def each
        return to_enum unless block_given?
        @operand.each do |tuple|
          yield extend_it(tuple)
        end
      end

      def insert(arg)
        case arg
        when Hash       then operand.insert(allbut_constants(arg))
        when Relation   then operand.insert(arg.allbut(the_constants.keys))
        when Enumerable then operand.insert(arg.map{|t| allbut_constants(t) })
        else
          super
        end
      end

      def update(tuple)
        shared = tuple.keys & the_constants.keys
        on_tuple = TupleAlgebra.project(tuple, shared)
        on_const = TupleAlgebra.project(the_constants, shared)
        raise InvalidUpdateError, "Cannot violate relvar predicate" unless on_tuple == on_const
        operand.update(allbut_constants(tuple))
      end

      def delete
        operand.delete
      end

      def to_ast
        [ :constants, operand.to_ast, the_constants.dup ]
      end

    public ### for internal reasons

      def _count
        operand._count
      end

    protected ### optimization

      def _page(type, ordering, page_index, options)
        attrs = ordering.map{|(k,v)| k}
        cs_attrs = the_constants.keys
        if (attrs & cs_attrs).empty?
          operand
            .page(ordering, page_index, options)
            .constants(the_constants)
        else
          super
        end
      end

      def _restrict(type, predicate)
        # bottom_p makes no reference to the_constants, top_p possibly
        # does...
        top_p, bottom_p = predicate.and_split(the_constants.keys)
        if top_p.tautology?
          # push all situation: predicate made no reference to the_constants
          result = operand
          result = result.restrict(bottom_p)
          result = result.constants(the_constants)
          result
        elsif (top_p.free_variables - the_constants.keys).empty?
          # top_p applies to the_constants only
          if eval = top_p.evaluate(the_constants)
            result = operand
            result = result.restrict(bottom_p)
            result = result.constants(the_constants)
            result
          else
            Relation.empty(type)
          end
        elsif bottom_p.tautology?
          # push none situation, no optimization possible since top_p
          # is not a tautology
          super
        else
          # top_p and bottom_p are complex predicates. Let apply each
          # of them
          result = operand
          result = result.restrict(bottom_p)
          result = result.constants(the_constants)
          result = result.restrict(top_p)
          result
        end
      rescue Predicate::NotSupportedError
        super
      end

    protected ### inspect

      def args
        [ the_constants ]
      end

    private

      def extend_it(tuple)
        tuple.merge(@the_constants)
      end

      def allbut_constants(tuple)
        TupleAlgebra.allbut(tuple, the_constants.keys)
      end

    end # class Constants
  end # module Operator
end # module Bmg

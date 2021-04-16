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

      def initialize(type, operand, constants)
        @type = type
        @operand = operand
        @constants = constants
      end

    protected

      attr_reader :constants

    public

      def each
        @operand.each do |tuple|
          yield extend_it(tuple)
        end
      end

      def insert(arg)
        case arg
        when Hash       then operand.insert(allbut_constants(arg))
        when Relation   then operand.insert(arg.allbut(constants.keys))
        when Enumerable then operand.insert(arg.map{|t| allbut_constants(t) })
        else
          super
        end
      end

      def update(tuple)
        shared = tuple.keys & constants.keys
        on_tuple = TupleAlgebra.project(tuple, shared)
        on_const = TupleAlgebra.project(constants, shared)
        raise InvalidUpdateError, "Cannot violate relvar predicate" unless on_tuple == on_const
        operand.update(allbut_constants(tuple))
      end

      def delete
        operand.delete
      end

      def to_ast
        [ :constants, operand.to_ast, constants.dup ]
      end

    public ### for internal reasons

      def _count
        operand._count
      end

    protected ### optimization

      def _page(type, ordering, page_index, options)
        attrs = ordering.map{|(k,v)| k}
        cs_attrs = constants.keys
        if (attrs & cs_attrs).empty?
          operand
            .page(ordering, page_index, options)
            .constants(constants)
        else
          super
        end
      end

      def _restrict(type, predicate)
        # bottom_p makes no reference to constants, top_p possibly
        # does...
        top_p, bottom_p = predicate.and_split(constants.keys)
        if top_p.tautology?
          # push all situation: predicate made no reference to constants
          result = operand
          result = result.restrict(bottom_p)
          result = result.constants(constants)
          result
        elsif (top_p.free_variables - constants.keys).empty?
          # top_p applies to constants only
          if eval = top_p.evaluate(constants)
            result = operand
            result = result.restrict(bottom_p)
            result = result.constants(constants)
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
          result = result.constants(constants)
          result = result.restrict(top_p)
          result
        end
      rescue Predicate::NotSupportedError
        super
      end

    protected ### inspect

      def args
        [ constants ]
      end

    private

      def extend_it(tuple)
        tuple.merge(@constants)
      end

      def allbut_constants(tuple)
        TupleAlgebra.allbut(tuple, constants.keys)
      end

    end # class Constants
  end # module Operator
end # module Bmg

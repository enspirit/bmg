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
      include Operator::Unary

      def initialize(type, operand, attrlist)
        @type = type
        @operand = operand
        @attrlist = attrlist
      end

    private

      attr_reader :attrlist

    public

      def each
        return to_enum unless block_given?
        seen = {}
        @operand.each do |tuple|
          projected = tuple_project(tuple)
          unless seen.has_key?(projected)
            yield(projected)
            seen[projected] = true
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

      def update(tuple, predicate = Predicate.tautology)
        operand.update(valid_tuple!(tuple), predicate)
      end

      def delete(predicate = Predicate.tautology)
        operand.delete(predicate)
      end

      def to_ast
        [ :project, operand.to_ast, attrlist ]
      end

    protected ### optimization

      def _restrict(type, predicate)
        operand.restrict(predicate).project(attrlist)
      end

      def _allbut(type, butlist)
        Project.new(type, @operand, attrlist - butlist)
      end

    protected ### inspect

      def args
        [ attrlist ]
      end

    private

      def tuple_project(tuple)
        tuple.dup.delete_if{|k,_| !@attrlist.include?(k) }
      end

      def valid_tuple!(tuple)
        offending = tuple.keys - attrlist
        raise InvalidUpdateError, "#{offending.inspect} cannot be updated" unless offending.empty?
        tuple
      end

    end # class Project
  end # module Operator
end # module Bmg

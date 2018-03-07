module Bmg
  module Relation
    #
    # The empty relation, of a given type.
    #
    # This relation implementation exists mostly for optimization
    # purposes, since knowing that a relation is empty allows
    # simplifying many expressions.
    #
    class Empty
      include Relation

      def initialize(type)
        @type = type
      end
      attr_reader :type

      def each(&bl)
      end

      def to_ast
        [ :empty ]
      end

    protected ### optimization

      def _allbut(type, *args)
        Empty.new(type)
      end

      def _autosummarize(type, *args)
        Empty.new(type)
      end

      def _autowrap(type, *args)
        Empty.new(type)
      end

      def _extend(type, *args)
        Empty.new(type)
      end

      def _image(type, *args)
        Empty.new(type)
      end

      def _project(type, *args)
        Empty.new(type)
      end

      def _rename(type, *args)
        Empty.new(type)
      end

      def _restrict(type, predicate)
        self
      end

      def _union(type, other, options)
        other
      end

    end # class Empty
  end # module Relation
end # module Bmg

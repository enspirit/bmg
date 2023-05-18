module Bmg
  module Redis
    class Singleton
      include Bmg::Relation

      def initialize(type, parent, tuple)
        @type = type
        @parent = parent
        @tuple = tuple
      end
      attr_accessor :type

      def each
        return to_enum unless block_given?

        yield(@tuple) if @tuple
      end

      def insert(tuple_or_tuples)
        @parent.insert(tuple_or_tuples)
        self
      end

      def update(updating, predicate = Predicate.tautology)
        @parent.update(updating, predicate & type.predicate)
        self
      end

      def delete(predicate = Predicate.tautology)
        @parent.delete(predicate & type.predicate)
      end

    end # class Singleton
  end # module Redis
end # module Bmg

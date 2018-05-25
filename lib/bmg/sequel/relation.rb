module Bmg
  module Sequel
    class Relation < Sql::Relation

      def initialize(type, builder, source, sequel_db)
        super(type, builder, source)
        @sequel_db = sequel_db
      end
      attr_reader :sequel_db

      def each(&bl)
        dataset.each(&bl)
      end

      def delete
        dataset.delete
      end

      def insert(arg)
        case arg
        when Hash then
          dataset.insert(arg.merge(type.predicate.constants))
        when Enumerable then
          dataset.multi_insert(arg.map { |x|
            x.merge(type.predicate.constants)
          })
        else
          dataset.insert(arg.merge(type.predicate.constants))
        end
      end

      def update(arg)
        dataset.update(arg)
      end

      def to_ast
        [:sequel, dataset.sql]
      end

      def to_sql
        dataset.sql
      end

      def to_s
        "(sequel #{dataset.sql})"
      end
      alias :inspect :to_s

    protected

      def dataset
        @dataset ||= Translator.new(sequel_db).call(self.expr)
      end

      def _instance(type, builder, expr)
        Relation.new(type, builder, expr, sequel_db)
      end

      def extract_compatible_sexpr(operand)
        return nil unless operand.is_a?(Bmg::Sequel::Relation)
        return nil unless self.sequel_db == operand.sequel_db
        operand.expr
      end

    end # class Relation
  end # module Sequel
end # module Bmg

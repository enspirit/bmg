module Bmg
  module Sequel
    class Relation < Sql::Relation

      def initialize(type, builder, source, sequel_db)
        super(type, builder, source)
        @sequel_db = sequel_db
      end
      attr_reader :sequel_db

      def each(&bl)
        return to_enum unless block_given?
        dataset.each(&bl)
      end

      def delete(predicate = Predicate.tautology)
        target = base_table
        unless predicate.tautology?
          compiled = compile_predicate(predicate)
          target = base_table.where(compiled)
        end
        target.delete
      end

      def insert(arg)
        case arg
        when Hash then
          base_table.insert(arg.merge(type.predicate.constants))
        when Enumerable then
          base_table.multi_insert(arg.map { |x|
            x.merge(type.predicate.constants)
          })
        else
          base_table.insert(arg.merge(type.predicate.constants))
        end
      end

      def update(arg, predicate = Predicate.tautology)
        target = base_table
        unless predicate.tautology?
          compiled = compile_predicate(predicate)
          target = base_table.where(compiled)
        end
        target.update(arg)
      end

      def _count
        dataset.count
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

      def base_table
        raise InvalidUpdateError unless self.expr.respond_to?(:table_spec)
        raise InvalidUpdateError unless self.expr.table_spec.first == :table_as
        sequel_db[self.expr.table_spec.table_name.to_sym]
      end

      def _instance(type, builder, expr)
        Relation.new(type, builder, expr, sequel_db)
      end

      def extract_compatible_sexpr(operand)
        return nil unless operand.is_a?(Bmg::Sequel::Relation)
        return nil unless self.sequel_db == operand.sequel_db
        operand.expr
      end

      def compile_predicate(predicate)
        Translator.new(sequel_db).compile_predicate(predicate)
      end

    end # class Relation
  end # module Sequel
end # module Bmg

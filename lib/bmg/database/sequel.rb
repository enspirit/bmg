module Bmg
  class Database
    class Sequel < Database

      DEFAULT_OPTIONS = {
      }

      def initialize(sequel_db, options = {})
        @sequel_db = sequel_db
        @sequel_db = ::Sequel.connect(@sequel_db) unless @sequel_db.is_a?(::Sequel::Database)
      end

      def method_missing(name, *args, &bl)
        return super(name, *args, &bl) unless args.empty? && bl.nil?
        raise NotSuchRelationError(name.to_s) unless @sequel_db.table_exists?(name)
        rel_for(name)
      end

      def each_relation_pair
        return to_enum(:each_relation_pair) unless block_given?

        @sequel_db.tables.each do |table|
          yield(table, rel_for(table))
        end
      end

    protected

      def rel_for(table_name)
        Bmg.sequel(table_name, @sequel_db)
      end

    end # class Sequel
  end # class Database
end # module Bmg

module Bmg
  module Sequel
    class TypeInference

      def initialize(sequel_db)
        @sequel_db = sequel_db
      end
      attr_reader :sequel_db

      def call(name)
        if type = sequel_db.bmg_schema_cache[name]
          type
        else
          type = Type.new
            .with_attrlist(attrlist(name))
            .with_keys(keys(name))
          ::Sequel.synchronize do
            sequel_db.bmg_schema_cache[name] = type
          end if sequel_db.cache_schema
          type
        end
      end

      def attrlist(name)
        sequel_db.schema(name).map{|(k,v)| k }
      end

      def keys(name)
        # take the indexes
        indexes = sequel_db
          .indexes(name)
          .values
          .select{|i| i[:unique] == true }
          .map{|i| i[:columns] }
          .sort{|a1, a2| a1.size <=> a2.size }

        # take single keys as well
        key = sequel_db
          .schema(name)
          .select{|(colname, colinfo)| colinfo[:primary_key] }
          .map(&:first)

        indexes.unshift(key) unless key.empty?

        indexes
      end

    end # class TypeInference
  end # module Sequel
end # module Bmg

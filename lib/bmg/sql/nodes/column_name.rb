module Bmg
  module Sql
    module ColumnName
      include Expr

      def qualifier
        nil
      end

      def as_name
        last
      end

      def would_be_name
        last
      end

      def is_computed?
        false
      end

      def to_sql(buffer, dialect)
        buffer << dialect.quote_identifier(last)
        buffer
      end

    end # module ColumnName
  end # module Sql
end # module Bmg

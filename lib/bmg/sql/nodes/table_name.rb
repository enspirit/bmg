module Bmg
  module Sql
    module TableName
      include Expr

      def value
        last
      end

      def to_sql(buffer, dialect)
        buffer << dialect.quote_identifier(last.to_s)
        buffer
      end

    end # module TableName
  end # module Sql
end # module Bmg

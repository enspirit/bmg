module Bmg
  module Sql
    module RangeVarName
      include Expr

      def qualifier
        last
      end

      def to_sql(buffer, dialect)
        buffer << dialect.quote_identifier(last)
        buffer
      end

    end # module RangeVarName
  end # module Sql
end # module Bmg

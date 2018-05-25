module Bmg
  module Sql
    module LimitClause
      include Expr

      LIMIT = "LIMIT"

      def limit
        last.to_i
      end

      def to_sql(buffer, dialect)
        buffer << LIMIT << SPACE << limit.to_s
        buffer
      end

    end # module LimitClause
  end # module Sql
end # module Bmg

module Bmg
  module Sql
    module OffsetClause
      include Expr

      OFFSET = "OFFSET"

      def offset
        last.to_i
      end

      def to_sql(buffer, dialect)
        buffer << OFFSET << SPACE << offset.to_s
        buffer
      end

    end # module OffsetClause
  end # module Sql
end # module Bmg

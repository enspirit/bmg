module Bmg
  module Sql
    module FromClause
      include Expr

      FROM = "FROM".freeze

      def table_spec
        last
      end

      def join?
        table_spec.join?
      end

      def to_sql(buffer, dialect)
        buffer << FROM << SPACE
        last.to_sql(buffer, dialect)
        buffer
      end

    end # module FromClause
  end # module Sql
end # module Bmg

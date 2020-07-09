module Bmg
  module Sql
    module Literal
      include Expr
      include Predicate::Expr

      def would_be_name
        nil
      end

      def is_computed?
        false
      end

      def to_sql(buffer, dialect)
        to_sql_literal(buffer, last)
        buffer
      end

    end # module Literal
  end # module Sql
end # module Bmg

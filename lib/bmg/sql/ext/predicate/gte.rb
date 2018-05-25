class Predicate
  module Gte

    def to_sql_operator
      Sql::Expr::GREATER_OR_EQUAL
    end

  end
end

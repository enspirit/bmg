class Predicate
  module Lte

    def to_sql_operator
      Sql::Expr::LESS_OR_EQUAL
    end

  end
end

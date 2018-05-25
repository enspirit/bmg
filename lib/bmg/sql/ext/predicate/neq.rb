class Predicate
  module Neq

    def to_sql_operator
      Sql::Expr::NOT_EQUAL
    end

  end
end

class Predicate
  module Eq

    def to_sql_operator
      Sql::Expr::EQUAL
    end

  end
end

class Predicate
  module Gt

    def to_sql_operator
      Sql::Expr::GREATER
    end

  end
end

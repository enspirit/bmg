class Predicate
  module Lt

    def to_sql_operator
      Sql::Expr::LESS
    end

  end
end

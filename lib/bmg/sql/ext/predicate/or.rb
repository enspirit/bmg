class Predicate
  module Or

    def to_sql_operator
      Sql::Expr::OR
    end

  end
end

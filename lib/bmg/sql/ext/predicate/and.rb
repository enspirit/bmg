class Predicate
  module And

    def to_sql_operator
      Sql::Expr::AND
    end

  end
end

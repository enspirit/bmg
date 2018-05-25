class Predicate
  module DyadicComp

    def to_sql(buffer, dialect)
      left.to_sql(buffer, dialect)
      buffer << Sql::Expr::SPACE << to_sql_operator << Sql::Expr::SPACE
      right.to_sql(buffer, dialect)
      buffer
    end

  end
end

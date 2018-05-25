class Predicate
  module Contradiction

    def to_sql(buffer, dialect)
      buffer << Sql::Expr::FALSE
      buffer
    end

  end
end

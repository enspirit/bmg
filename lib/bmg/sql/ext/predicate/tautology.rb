class Predicate
  module Tautology

    def to_sql(buffer, dialect)
      buffer << Sql::Expr::TRUE
      buffer
    end

  end
end

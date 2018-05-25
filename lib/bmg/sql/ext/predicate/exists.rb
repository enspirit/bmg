class Predicate
  module Exists
    include Expr

    def to_sql(buffer, dialect)
      buffer << Sql::Expr::EXISTS
      last.to_sql(buffer, dialect)
      buffer
    end

  end
end

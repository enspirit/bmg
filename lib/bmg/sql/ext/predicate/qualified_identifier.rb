class Predicate
  module QualifiedIdentifier

    def to_sql(buffer, dialect)
      buffer << dialect.quote_identifier(qualifier)
      buffer << Sql::Expr::DOT
      buffer << dialect.quote_identifier(name)
      buffer
    end

  end
end

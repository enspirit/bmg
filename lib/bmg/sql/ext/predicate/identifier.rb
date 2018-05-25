class Predicate
  module Identifier

    def to_sql(buffer, dialect)
      buffer << dialect.quote_identifier(name)
      buffer
    end

  end
end

class Predicate
  module Literal

    def to_sql(buffer, dialect)
      to_sql_literal(buffer, value)
      buffer
    end

  end
end

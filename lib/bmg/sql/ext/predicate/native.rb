class Predicate
  module Native

    def to_sql(buffer, dialect)
      raise NotSupportedError, "Unable to compile native predicates to SQL"
    end

  end
end

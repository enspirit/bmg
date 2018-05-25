class Predicate
  module NadicBool

    def to_sql(buffer, dialect)
      each_with_index do |child, index|
        next if index == 0
        unless index == 1
          buffer << Sql::Expr::SPACE << to_sql_operator << Sql::Expr::SPACE
        end
        child.to_sql(buffer, dialect)
      end
      buffer
    end

  end
end

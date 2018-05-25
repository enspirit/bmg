class Predicate
  module In

    def subquery?
      Sql::Expr === last
    end

    def subquery
      subquery? ? last : nil
    end

    def to_sql(buffer, dialect)
      identifier.to_sql(buffer, dialect)
      buffer << Sql::Expr::SPACE << Sql::Expr::IN << Sql::Expr::SPACE
      if subquery?
        values.to_sql(buffer, dialect)
      else
        buffer << Sql::Expr::LEFT_PARENTHESE
        values.each_with_index do |val,index|
          buffer << Sql::Expr::COMMA << Sql::Expr::SPACE unless index==0
          to_sql_literal(buffer, val)
        end
        buffer << Sql::Expr::RIGHT_PARENTHESE
      end
      buffer
    end

  end
end

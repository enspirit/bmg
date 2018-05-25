class Predicate
  module Expr

    def to_sql_literal(buffer, value)
      case value
      when TrueClass
        buffer << Sql::Expr::TRUE
      when FalseClass
        buffer << Sql::Expr::FALSE
      when Integer, Float
        buffer << value.to_s
      else
        buffer << Sql::Expr::QUOTE << value.to_s << Sql::Expr::QUOTE
      end
    end

  end
end

module Bmg
  module Sql
    module OrderByClause
      include Expr

      ORDER_BY = "ORDER BY".freeze

      def to_ordering
        @ordering ||= sexpr_body.map{|x|
          [x.as_name.to_sym, x.direction.to_sym]
        }
      end

      def to_sql(buffer, dialect)
        buffer << ORDER_BY << SPACE
        each_child do |item,index|
          buffer << COMMA << SPACE unless index == 0
          item.to_sql(buffer, dialect)
        end
        buffer
      end

    end # module OrderByClause
  end # module Sql
end # module Bmg

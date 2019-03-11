module Bmg
  module Sql
    module GroupByClause
      include Expr

      GROUP_BY = "GROUP BY".freeze

      def to_sql(buffer, dialect)
        return buffer if size == 1
        buffer << GROUP_BY << SPACE
        each_child do |item,index|
          buffer << COMMA << SPACE unless index == 0
          item.to_sql(buffer, dialect)
        end
        buffer
      end

    end # module GroupByClause
  end # module Sql
end # module Bmg

module Bmg
  module Sql
    module WithSpec
      include Expr

      def to_sql(buffer, dialect)
        each_child do |child,index|
          buffer << COMMA << SPACE unless index==0
          child.to_sql(buffer, dialect)
        end
        buffer
      end

      def to_hash
        hash = {}
        each_child do |child|
          hash[child.table_name.value] = child.subquery
        end
        hash
      end

    end # module WithSpec
  end # module Sql
end # module Bmg

module Bmg
  module Sql
    module SubqueryAs
      include Expr

      def left
        self[1]
      end
      alias :subquery :left

      def right
        self[2]
      end

      def as_name
        self[2].last
      end

      def to_sql(buffer, dialect)
        left.to_sql(buffer, dialect)
        buffer << SPACE << AS << SPACE
        right.to_sql(buffer, dialect)
        buffer
      end

    end # module SubqueryAs
  end # module Sql
end # module Bmg

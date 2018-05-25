module Bmg
  module Sql
    module TableAs
      include Expr

      def left
        self[1]
      end

      def right
        self[2]
      end

      def table_name
        self[1].last
      end

      def as_name
        self[2].last
      end

      def to_sql(buffer, dialect)
        self[1].to_sql(buffer, dialect)
        buffer << SPACE << AS << SPACE
        self[2].to_sql(buffer, dialect)
        buffer
      end

    end # module TableAs
  end # module Sql
end # module Bmg

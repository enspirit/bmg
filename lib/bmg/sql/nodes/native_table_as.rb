module Bmg
  module Sql
    module NativeTableAs
      include Expr

      def left
        self[1]
      end

      def right
        self[2]
      end

      def native_table
        self[1].last
      end

      def as_name
        self[2].last
      end

      def to_sql(buffer, dialect)
        buffer << self[1].to_s
        buffer << SPACE << AS << SPACE
        self[2].to_sql(buffer, dialect)
        buffer
      end

    end # module NativeTableAs
  end # module Sql
end # module Bmg

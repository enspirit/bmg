module Bmg
  module Sql
    module SelectItem
      include Expr

      def left
        self[1]
      end

      def right
        self[2]
      end

      def qualifier
        left.qualifier
      end

      def would_be_name
        left.would_be_name
      end

      def as_name
        last.as_name
      end

      def to_sql(buffer, dialect)
        self[1].to_sql(buffer, dialect)
        unless would_be_name == as_name
          buffer << SPACE << AS << SPACE
          last.to_sql(buffer, dialect)
        end
        buffer
      end

    end # module SelectItem
  end # module Sql
end # module Bmg

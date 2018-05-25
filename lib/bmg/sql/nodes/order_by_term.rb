module Bmg
  module Sql
    module OrderByTerm
      include Expr

      def qualified_name
        self[1]
      end

      def qualifier
        qualified_name.qualifier
      end

      def as_name
        qualified_name.as_name
      end

      def direction
        last
      end

      def to_sql(buffer, dialect)
        self[1].to_sql(buffer, dialect)
        buffer << SPACE << direction.upcase
        buffer
      end

    end # module OrderByTerm
  end # module Sql
end # module Bmg

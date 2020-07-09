module Bmg
  module Sql
    #
    # [:qualified_name,
    #   [:range_var_name `qualifier`],
    #   [:column_name, `as_name`] ]
    #
    module QualifiedName
      include Expr

      def qualifier
        self[1].qualifier
      end

      def as_name
        last.as_name
      end

      def would_be_name
        as_name
      end

      def is_computed?
        false
      end

      def to_sql(buffer, dialect)
        self[1].to_sql(buffer, dialect)
        buffer << '.'
        self[2].to_sql(buffer, dialect)
        buffer
      end

    end # module QualifiedName
  end # module Sql
end # module Bmg

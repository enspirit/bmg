module Bmg
  module Sql
    module WithExp
      include Expr
      extend Forwardable

      WITH = "WITH".freeze

      def with_exp?
        true
      end

      def with_spec
        self[1]
      end

      def select_exp
        last
      end
      def_delegators :select_exp, :select_list,
                                  :where_clause,
                                  :predicate,
                                  :from_clause,
                                  :table_spec,
                                  :order_by_clause,
                                  :limit_clause,
                                  :offset_clause,
                                  :desaliaser,
                                  :to_attr_list,
                                  :to_ordering,
                                  :all?,
                                  :distinct?,
                                  :set_operator?,
                                  :limit_or_offset?,
                                  :join?,
                                  :should_be_reused?,
                                  :is_table_dee?

    # to_xxx

      def to_sql(buffer, dialect)
        buffer << WITH << SPACE
        self[1].to_sql(buffer, dialect)
        buffer << SPACE
        self[2].to_sql(buffer, dialect, false)
        buffer
      end

    end # module WithExp
  end # module Sql
end # module Bmg

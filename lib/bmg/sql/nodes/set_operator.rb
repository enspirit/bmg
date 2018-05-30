module Bmg
  module Sql
    module SetOperator
      include Expr

      def head_expr
        self[2]
      end

      def tail_exprs
        self[3..-1]
      end

      def set_quantifier
        self[1]
      end

      def with_exp?
        false
      end

      def set_operator?
        true
      end

      def is_table_dee?
        false
      end

      def distinct?
        set_quantifier.distinct?
      end

      def all?
        set_quantifier.all?
      end

      def should_be_reused?
        true
      end

      def order_by_clause
        nil
      end

      def to_attr_list
        self.last.to_attr_list
      end

      def to_sql(buffer, dialect, parenthesize = !buffer.empty?)
        if parenthesize
          sql_parenthesized(buffer){|b| to_sql(b, dialect, false) }
        else
          left.to_sql(buffer, dialect, true)
          buffer << SPACE << keyword
          unless distinct?
            buffer << SPACE
            set_quantifier.to_sql(buffer, dialect)
          end
          buffer << SPACE
          right.to_sql(buffer, dialect, true)
          buffer
        end
      end

    end # module SetOperator
  end # module Sql
end # module Bmg

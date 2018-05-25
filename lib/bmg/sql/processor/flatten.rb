module Bmg
  module Sql
    class Processor
      class Flatten < Processor

        def on_with_exp(sexpr)
          @subqueries = sexpr.with_spec.to_hash
          apply(sexpr.select_exp)
        end
        attr_reader :subqueries

        alias :on_select_exp :copy_and_apply
        alias :on_missing    :copy_and_apply

        def on_table_as(sexpr)
          return sexpr unless subqueries
          return sexpr unless subquery = subqueries[sexpr.table_name]
          [ :subquery_as, apply(subquery), sexpr.right ]
        end

      end # class Flatten
    end # class Processor
  end # module Sql
end # module Bmg

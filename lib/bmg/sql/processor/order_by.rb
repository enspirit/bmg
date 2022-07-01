module Bmg
  module Sql
    class Processor
      class OrderBy < Processor

        def initialize(ordering, builder)
          super(builder)
          @ordering = ordering
        end
        attr_reader :ordering

        def on_set_operator(sexpr)
          call(builder.from_self(sexpr))
        end
        alias :on_union     :on_set_operator
        alias :on_except    :on_set_operator
        alias :on_intersect :on_set_operator

        def on_select_exp(sexpr)
          if sexpr.order_by? || sexpr.group_by?
            sexpr = builder.from_self(sexpr)
            call(sexpr)
          else
            needed = builder.order_by_clause(ordering, &sexpr.desaliaser)
            sexpr.dup.push(needed)
          end
        end

      end # class OrderBy
    end # class Processor
  end # module Sql
end # module Bmg

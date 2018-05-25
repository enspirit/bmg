module Bmg
  module Sql
    class Processor
      class LimitOffset < Processor

        def initialize(limit, offset, builder)
          super(builder)
          @limit = limit
          @offset = offset
        end
        attr_reader :limit, :offset

        def on_set_operator(sexpr)
          apply(builder.from_self(sexpr))
        end
        alias :on_union     :on_set_operator
        alias :on_except    :on_set_operator
        alias :on_intersect :on_set_operator

        def on_select_exp(sexpr)
          sexpr  = builder.from_self(sexpr) if obc = sexpr.limit_or_offset?
          limit_clause = builder.limit_clause(limit)
          offset_clause = builder.offset_clause(offset)
          sexpr.with_push(limit_clause, offset_clause)
        end

      end # class LimitOffset
    end # class Processor
  end # module Sql
end # module Bmg

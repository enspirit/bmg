module Bmg
  module Sql
    class Processor
      class Star < Processor

        def on_select_exp(sexpr)
          if sexpr.from_clause
            sexpr.with_update(:select_list, builder.select_star)
          else
            sexpr
          end
        end

      end # class Star
    end # class Processor
  end # module Sql
end # module Bmg

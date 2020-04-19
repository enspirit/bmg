module Bmg
  module Sql
    class Processor
      class Bind < Processor

        def initialize(binding, builder)
          super(builder)
          @binding = binding
        end

        def on_select_exp(sexpr)
          if w = sexpr.where_clause
            pred = Predicate::Grammar.sexpr(w.predicate.bind(@binding))
            sexpr.with_update(:where_clause, [ :where_clause, pred ])
          else
            sexpr
          end
        end

      end # class Bind
    end # class Processor
  end # module Sql
end # module Bmg

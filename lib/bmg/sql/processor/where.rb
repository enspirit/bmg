module Bmg
  module Sql
    class Processor
      class Where < Processor

        def initialize(predicate, builder)
          super(builder)
          @predicate = predicate
        end

        def on_union(sexpr)
          non_falsy = sexpr[2..-1].reject{|expr| falsy?(expr) }
          if non_falsy.empty?
            apply(sexpr.head_expr)
          elsif non_falsy.size == 1
            apply(non_falsy.first)
          else
            [sexpr[0], sexpr[1]] + non_falsy.map{|nf| apply(nf) }
          end
        end

        def on_select_exp(sexpr)
          if sexpr.group_by_clause
            sexpr = builder.from_self(sexpr)
            call(sexpr)
          else
            pred = @predicate.rename(sexpr.desaliaser(true))
            if sexpr.where_clause
              sexpr_p = Predicate.new(sexpr.where_clause.predicate)
              sexpr.with_update(:where_clause, [ :where_clause, (sexpr_p & pred).sexpr ])
            else
              sexpr.with_insert(4, [ :where_clause, pred.sexpr ])
            end
          end
        end

      private

        def falsy?(sexpr)
          return false unless sexpr.respond_to?(:predicate)
          return false if sexpr.predicate.nil?
          left  = Predicate.new(Predicate::Grammar.sexpr(sexpr.predicate)).unqualify
          right = Predicate.new(Predicate::Grammar.sexpr(@predicate.sexpr)).unqualify
          return (left & right).contradiction?
        end

      end # class Where
    end # class Processor
  end # module Sql
end # module Bmg

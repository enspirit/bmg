module Bmg
  module Sql
    class Processor
      module JoinSupport

        def on_main_exp(sexpr)
          joined = apply_join_strategy(sexpr.select_exp, right.select_exp)
          merge_with_exps(sexpr, right, joined)
        end
        alias :on_with_exp   :on_main_exp
        alias :on_select_exp :on_main_exp

      private

        def join_predicate(left, right, commons)
          left_d, right_d = left.desaliaser, right.desaliaser
          commons.to_a.inject(tautology){|cond, attr|
            left_attr, right_attr = left_d[attr], right_d[attr]
            left_p  = Predicate::Factory.qualified_identifier(left_attr.qualifier, left_attr.as_name)
            right_p = Predicate::Factory.qualified_identifier(right_attr.qualifier, right_attr.as_name)
            cond &= Predicate::Factory.eq(left_p, right_p)
          }
        end

      end # class JoinSupport
    end # class Processor
  end # module Sql
end # module Bmg

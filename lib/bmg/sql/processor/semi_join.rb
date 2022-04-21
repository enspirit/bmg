module Bmg
  module Sql
    class Processor
      class SemiJoin < Processor
        include JoinSupport

        def initialize(right, on, negate = false, builder)
          super(builder)
          @right  = right
          @on = on
          @negate = negate
        end
        attr_reader :right, :on, :negate

        def call(sexpr)
          if sexpr.set_operator?
            call(builder.from_self(sexpr))
          elsif right.set_operator?
            SemiJoin.new(builder.from_self(right), negate, builder).call(sexpr)
          else
            super(sexpr)
          end
        end

      private

        def apply_join_strategy(left, right)
          predicate = build_semijoin_predicate(left, right)
          expand_where_clause(left, negate ? !predicate : predicate)
        end

        def build_semijoin_predicate(left, right)
          if right.is_table_dee?
            right.where_clause.predicate
          else
            commons = self.on
            subquery = Clip.new(commons, false, :star, builder).call(right)
            subquery = Requalify.new(builder).call(subquery)
            subquery = All.new(builder).call(subquery)
            if commons.size == 0
              builder.exists(subquery)
            else
              join_pre  = join_predicate(left, subquery, commons)
              subquery  = expand_where_clause(subquery, join_pre)
              subquery  = Star.new(builder).call(subquery)
              builder.exists(subquery)
            end
          end
        end

        def expand_where_clause(sexpr, predicate)
          Grammar.sexpr \
            [ :select_exp,
              sexpr.set_quantifier,
              sexpr.select_list,
              sexpr.from_clause,
              [ :where_clause, (sexpr.predicate || tautology) & predicate ],
              sexpr.order_by_clause,
              sexpr.limit_clause,
              sexpr.offset_clause ].compact
        end

      end # class SemiJoin
    end # class Processor
  end # module Sql
end # module Bmg

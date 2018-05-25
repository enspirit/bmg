module Bmg
  module Sql
    class Processor
      class Join < Processor
        include JoinSupport

        def initialize(right, builder)
          super(builder)
          @right = right
        end
        attr_reader :right

        def call(sexpr)
          if unjoinable?(sexpr)
            call(builder.from_self(sexpr))
          elsif unjoinable?(right)
            Join.new(builder.from_self(right), builder).call(sexpr)
          else
            super(sexpr)
          end
        end

      private

        def apply_join_strategy(left, right)
          [ :select_exp,
            join_set_quantifiers(left, right),
            join_select_lists(left, right),
            join_from_clauses(left, right),
            join_where_clauses(left, right),
            join_order_by_clauses(left, right) ].compact
        end

        def unjoinable?(sexpr)
          sexpr.set_operator? or sexpr.limit_or_offset? or sexpr.join?
        end

        def join_set_quantifiers(left, right)
          left_q, right_q = left.set_quantifier, right.set_quantifier
          left_q == right_q ? left_q : builder.distinct
        end

        def join_select_lists(left, right)
          left_list, right_list = left.select_list, right.select_list
          list = left_list.dup
          right_list.each_child do |child, index|
            list << child unless left_list.knows?(child.as_name)
          end
          list
        end

        def join_from_clauses(left, right)
          joincon = join_predicate(left, right)
          join = if joincon.tautology?
            [:cross_join, left.table_spec, right.table_spec]
          else
            [:inner_join, left.table_spec, right.table_spec, joincon]
          end
          left.from_clause.with_update(-1, join)
        end

        def join_where_clauses(left, right)
          predicate = [ tautology, left.predicate, right.predicate ].compact
          case predicate.size
          when 1 then nil
          when 2 then [ :where_clause, predicate.last ]
          else [ :where_clause, predicate.reduce(:&) ]
          end
        end

        def join_order_by_clauses(left, right)
          order_by = [ left.order_by_clause, right.order_by_clause ].compact
          return order_by.first if order_by.size <= 1
          order_by.first + order_by.last.sexpr_body
        end

      end # class Join
    end # class Processor
  end # module Sql
end # module Bmg

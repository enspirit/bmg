module Bmg
  module Sql
    class Processor
      class Requalify < Processor

        def initialize(builder)
          super
          @requalify = Hash.new{|h,k|
            h[k.to_s] = builder.next_qualifier!
          }
        end
        attr_reader :requalify 

        alias :on_select_exp :copy_and_apply
        alias :on_missing :copy_and_apply

        def on_range_var_name(sexpr)
          Grammar.sexpr [:range_var_name, requalify[sexpr.qualifier.to_s] ]
        end

        def on_where_clause(sexpr)
          pred = Predicate::Grammar.sexpr(apply(sexpr.predicate))
          sexpr([:where_clause, pred])
        end

        def on_qualified_identifier(sexpr)
          Predicate::Factory.qualified_identifier(requalify[sexpr.qualifier.to_s].to_sym, sexpr.name.to_sym)
        end

      end # class Requalify
    end # class Processor
  end # module Sql
end # module Bmg

module Bmg
  module Sql
    class Processor
      class Merge < Processor

        def initialize(kind, all, right, builder)
          super(builder)
          @kind = kind
          @all = all
          @right = right
        end

        def on_with_exp(sexpr)
          if @right.with_exp?
            reordered = Reorder.new(sexpr.to_attr_list, builder).call(@right)
            main = [ @kind, modifier, sexpr.select_exp, reordered.select_exp ]
            merge_with_exps(sexpr, reordered, main)
          else
            [ :with_exp,
              sexpr.with_spec,
              apply(sexpr.last) ]
          end
        end

        def on_nonjoin_exp(sexpr)
          reordered = Reorder.new(sexpr.to_attr_list, builder).call(@right)
          if @right.with_exp?
            [ :with_exp,
              reordered.with_spec,
              [ @kind, modifier, sexpr, reordered.select_exp ] ]
          else
            [ @kind, modifier, sexpr, reordered ]
          end
        end
        alias :on_union      :on_nonjoin_exp
        alias :on_except     :on_nonjoin_exp
        alias :on_intersect  :on_nonjoin_exp
        alias :on_select_exp :on_nonjoin_exp

      private

        def modifier
          @all ? builder.all : builder.distinct
        end

      end # class Merge
    end # class Processor
  end # module Sql
end # module Bmg

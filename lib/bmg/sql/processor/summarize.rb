module Bmg
  module Sql
    class Processor
      class Summarize < Processor

        def initialize(by, summarization, builder)
          super(builder)
          @by = by
          @summarization = summarization
        end
        attr_reader :by, :summarization

        def on_set_operator(sexpr)
          call(builder.from_self(sexpr))
        end
        alias :on_union     :on_set_operator
        alias :on_except    :on_set_operator
        alias :on_intersect :on_set_operator

        def on_select_exp(sexpr)
          if obc = sexpr.group_by_clause
            sexpr = builder.from_self(sexpr)
            call(sexpr)
          else
            sexpr = sexpr.with_update(:select_list, apply(sexpr.select_list))
            group_by = builder.group_by_clause(by, &sexpr.desaliaser)
            sexpr.push(group_by)
          end
        end

        def on_select_list(sexpr)
          by_list = sexpr.sexpr_body.select{|select_item|
            by.include?(select_item.last.last.to_sym)
          }
          group_list = summarization.map{|attr,summarizer|
            [:select_item,
              [ :summarizer,
                summarizer.to_summarizer_name,
                sexpr.desaliaser[summarizer.functor] ],
              [:column_name, attr.to_s] ]
          }
          ([:select_list] + by_list + group_list)
        end

      end # class Summarize
    end # class Processor
  end # module Sql
end # module Bmg

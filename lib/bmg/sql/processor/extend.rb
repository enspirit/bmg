module Bmg
  module Sql
    class Processor
      class Extend < Processor

        def initialize(extension, builder)
          super(builder)
          @extension = extension
        end
        attr_reader :extension

        def on_set_operator(sexpr)
          apply(builder.from_self(sexpr))
        end
        alias :on_union     :on_set_operator
        alias :on_except    :on_set_operator
        alias :on_intersect :on_set_operator

        def on_select_star(sexpr)
          raise NotImplementedError, "Extend on * is not supported"
        end

        def on_select_list(sexpr)
          sexpr + extension.each_pair.map{|(k,v)|
            desaliased = sexpr.desaliaser[v]
            [:select_item, desaliased, [:column_name, k] ]
          }
        end

      end # class Extend
    end # class Processor
  end # module Sql
end # module Bmg

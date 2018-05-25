module Bmg
  module Sql
    class Processor
      class Clip < Processor

        def initialize(attributes, allbut = false, on_empty = :is_table_dee, builder)
          super(builder)
          @attributes = attributes
          @allbut = allbut
          @on_empty = on_empty
        end
        attr_reader :attributes, :on_empty

        def allbut?
          @allbut
        end

        def on_set_operator(sexpr)
          apply(builder.from_self(sexpr))
        end
        alias :on_union     :on_set_operator
        alias :on_except    :on_set_operator
        alias :on_intersect :on_set_operator

        def on_select_exp(sexpr)
          catch(:empty){ return super(sexpr) }
          send("select_#{on_empty}", sexpr)
        end

        def on_select_star(sexpr)
          raise NotImplementedError, "Allbut on * is not supported" if allbut?
          builder.select_list(attributes, builder.last_qualifier)
        end

        def on_select_list(sexpr)
          allbut = self.allbut?
          result = sexpr.select{|child|
            (child == :select_list) or
            attributes.include?(child.as_name.to_sym) == !allbut
          }
          (result.size==1) ? throw(:empty) : result
        end

      private

        def select_is_table_dee(sexpr)
          builder.select_is_table_dee(select_star(sexpr))
        end

        def select_star(sexpr)
          All.new(builder).call(Star.new(builder).call(sexpr))
        end

      end # class Clip
    end # class Processor
  end # module Sql
end # module Bmg

module Bmg
  module Sql
    class Processor
      class Constants < Processor

        def initialize(constants, builder)
          super(builder)
          @constants = constants
        end
        attr_reader :constants

        def on_set_operator(sexpr)
          apply(builder.from_self(sexpr))
        end
        alias :on_union     :on_set_operator
        alias :on_except    :on_set_operator
        alias :on_intersect :on_set_operator

        def on_select_star(sexpr)
          raise NotImplementedError, "Constants on * is not supported"
        end

        def on_select_list(sexpr)
          sexpr + constants.each_pair.map{|(k,v)|
            builder.select_literal_item(v, k)
          }
        end

      end # class Constants
    end # class Processor
  end # module Sql
end # module Bmg

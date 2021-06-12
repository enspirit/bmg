module Bmg
  module Sql
    class Processor
      class Transform < Processor

        def initialize(transformation, options, builder)
          raise NotSupportedError unless options.empty?
          super(builder)
          @transformation = transformation
        end
        attr_reader :transformation

        def on_select_list(sexpr)
          sexpr.each_with_index.map{|child,index|
            index == 0 ? child : apply(child)
          }
        end

        def on_select_item(sexpr)
          as = sexpr.as_name.to_sym
          case t = transformation[as]
          when NilClass
            sexpr
          when Class
            sexpr([:select_item,
              [:func_call,
                :cast,
                sexpr[1],
                [ :literal, t ]
              ],
              sexpr[2]
            ])
          else
            raise NotSupportedError
          end
        end

      end # class Transform
    end # class Processor
  end # module Sql
end # module Bmg

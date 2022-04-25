module Bmg
  module Sql
    class Processor
      class Transform < Processor

        module SplitSupported
          extend(self)

          def split_supported(tr, &bl)
            case tr
            when Array
              i = tr.find_index{|x| !bl.call(x) } || tr.size
              [tr[0...i], tr[i..-1]].map{|a|
                case a.size
                when 0 then nil
                when 1 then a.first
                else a
                end
              }
            when Hash
              tr.inject([{}, {}]){|(sup,unsup),(k,v)|
                mine, hers = _split_supported(v, &bl)
                [
                  sup.merge(k => mine),
                  unsup.merge(k => hers)
                ].map(&:compact)
              }.map{|h| h.empty? ? nil : h }
            else
              _split_supported(tr, &bl)
            end
          end

          def _split_supported(tr, &bl)
            if tr.is_a?(Array)
              split_supported(tr, &bl)
            else
              bl.call(tr) ? [tr, nil] : [nil, tr]
            end
          end
        end # module SplitSupported

        def initialize(transformation, options, builder)
          raise NotSupportedError unless options.empty?
          super(builder)
          @transformation = transformation
        end
        attr_reader :transformation

        def self.split_supported(*args, &bl)
          SplitSupported.split_supported(*args, &bl)
        end

        def on_select_list(sexpr)
          sexpr.each_with_index.map{|child,index|
            index == 0 ? child : apply(child)
          }
        end

        AstAble = ->(t){ t.respond_to?(:to_sql_ast) }

        def on_select_item(sexpr)
          as = sexpr.as_name.to_sym
          case t = transformation_for(as)
          when NilClass
            sexpr
          when AstAble, Class, Array
            sexpr([:select_item,
              func_call_node(sexpr, Array(t).reverse),
              sexpr[2]
            ])
          else
            raise NotSupportedError
          end
        end

      private

        def func_call_node(sexpr, ts)
          _func_call_node(sexpr, ts.first, ts[1..-1])
        end

        def _func_call_node(sexpr, head, tail)
          inside = if tail.empty?
            sexpr[1]
          else
            _func_call_node(sexpr, tail.first, tail[1..-1])
          end
          case head
          when AstAble
            head.to_sql_ast(self, inside)
          when Class
            [:func_call,
              :cast,
              inside,
              [ :literal, head ] ]
          end
        end

        def transformation_for(as)
          case t = transformation
          when Class then t
          when Hash  then t[as]
          when Array then t
          else
            raise Sql::NotSupportedError, "Unable to use `#{as}` for `transform`"
          end
        end

      end # class Transform
    end # class Processor
  end # module Sql
end # module Bmg

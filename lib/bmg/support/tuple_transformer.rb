module Bmg
  class TupleTransformer

    Callable = ->(t) { t.respond_to?(:call) }

    def initialize(transformation)
      @transformation = transformation
    end

    def self.new(arg)
      return arg if arg.is_a?(TupleTransformer)
      super
    end

    def call(tuple)
      transform_tuple(tuple, @transformation)
    end

    def knows_attrlist?
      @transformation.is_a?(Hash)
    end

    def to_attrlist
      @transformation.keys
    end

    private

      def transform_tuple(tuple, with)
        case with
        when Symbol, Proc, Regexp, Callable
          tuple.each_with_object({}){|(k,v),dup|
            dup[k] = transform_attr(v, with)
          }
        when Hash
          with.each_with_object(tuple.dup){|(k,v),dup|
            case k
            when Symbol
              dup[k] = transform_attr(dup[k], v)
            when Class
              dup.keys.each do |attrname|
                dup[attrname] = transform_attr(dup[attrname], v) if dup[attrname].is_a?(k)
              end
            else
              raise ArgumentError, "Unexpected transformation `#{with.inspect}`"
            end
          }
        when Array
          with.inject(tuple){|dup,on|
            transform_tuple(dup, on)
          }
        when Type
          unless with.knows_types?
            raise ArgumentError, "Heading must specify the attribute types`"
          end
          transform_tuple(tuple, with.heading)
        else
          raise ArgumentError, "Unexpected transformation `#{with.inspect}`"
        end
      end

      def transform_attr(value, with)
        case with
        when Symbol
          value.send(with)
        when Regexp
          m = with.match(value.to_s)
          m.nil? ? m : m.to_s
        when Class
          return value if value.nil?
          if with.respond_to?(:parse)
            with.parse(value)
          elsif with == Integer
            Integer(value)
          elsif with == Float
            Float(value)
          elsif with == String
            value.to_s
          else
            raise ArgumentError, "#{with} should respond to `parse`"
          end
        when Proc, Callable
          with.call(value)
        when Hash
          with[value]
        when Type
          unless with.knows_types?
            raise ArgumentError, "Heading must specify the attribute types`"
          end
          case value
          when Hash
            transform_tuple(value, with.heading)
          when Enumerable
            Relation.new(value.map{|t| transform_tuple(t, with.heading) })
          else
            raise ArgumentError, "Unexpected value `#{value.inspect}`"
          end
        else
          raise ArgumentError, "Unexpected transformation `#{with.inspect}`"
        end
      end

  end # module TupleTransformer
end # module Bmg

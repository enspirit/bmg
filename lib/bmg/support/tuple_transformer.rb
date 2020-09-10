module Bmg
  class TupleTransformer

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
        when Symbol
          tuple.each_with_object({}){|(k,v),dup|
            dup[k] = transform_attr(v, with)
          }
        when Proc
          tuple.each_with_object({}){|(k,v),dup|
            dup[k] = transform_attr(v, with)
          }
        when Hash
          with.each_with_object(tuple.dup){|(k,v),dup|
            dup[k] = transform_attr(dup[k], v)
          }
        when Array
          with.inject(tuple){|dup,on|
            transform_tuple(dup, on)
          }
        else
          raise ArgumentError, "Unexpected transformation `#{with.inspect}`"
        end
      end

      def transform_attr(value, with)
        case with
        when Symbol
          value.send(with)
        when Proc
          with.call(value)
        when Hash
          with[value]
        else
          raise ArgumentError, "Unexpected transformation `#{with.inspect}`"
        end
      end

  end # module TupleTransformer
end # module Bmg
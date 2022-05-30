module Bmg
  module Redis
    class Serializer
      class Json < Serializer

        def serialize(tuple)
          tuple.to_json
        end

        def deserialize(serialized)
          parsed = JSON.parse(serialized)
          TupleAlgebra.symbolize_keys(parsed)
        end

      end # class Json
    end # class Serializer
  end # module Redis
end # module Bmg

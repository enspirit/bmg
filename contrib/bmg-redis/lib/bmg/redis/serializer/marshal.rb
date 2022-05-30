module Bmg
  module Redis
    class Serializer
      class Marshal < Serializer

        def serialize(tuple)
          ::Marshal.dump(tuple)
        end

        def deserialize(serialized)
          ::Marshal.load(serialized)
        end

      end # class Marshal
    end # class Serializer
  end # module Redis
end # module Bmg

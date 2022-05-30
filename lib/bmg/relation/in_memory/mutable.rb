module Bmg
  module Relation
    class InMemory
      class Mutable < InMemory
        def insert(arg)
          raise ArgumentError unless arg.is_a?(Hash)

          @operand << arg.dup
        end

        def update(updating, predicate = Predicate.tautology)
          @operand = @operand.map{|t|
            predicate.call(t) ? t.merge(updating) : t
          }
        end

        def delete(predicate = Predicate.tautology)
          @operand = @operand.select{|t| predicate.call(t) }
        end
      end # class Mutable
    end # class InMemory
  end # module Relation
end # module Bmg

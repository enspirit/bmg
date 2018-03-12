module Bmg
  module Relation
    class Cached
      include Relation

      def initialize(operand, key_attributes, cache)
        @operand = operand
        @key_attributes = key_attributes
        @cache = cache
      end

    protected

      attr_reader :operand, :key_attributes, :cache

    public

      def type
        operand.type
      end

      def each(&bl)
        predicate = operand.type.predicate
        constants = predicate.constants
        if (key_attributes - constants.keys).empty?
          # The predicate is stronger or equal to a equality predicate on the
          # key attributes
          key = constants.reject{|k,v| !key_attributes.include?(k) }
          if cache.has_key?(key)
            # Cache success, but as the predicate might be stronger, we still
            # need to restrict the cache result itself
            cache[key].restrict(predicate).each(&bl)
          elsif predicate == Predicate.coerce(key)
            # Cache miss: let save for next round
            to_cache = Relation.new operand.to_a, operand.type
            cache[key] = to_cache
            to_cache.each(&bl)
          else
            operand.each(&bl)
          end
        else
          # Predicate is not stronger or equal, cache cannot be used at all
          operand.each(&bl)
        end
      end

    protected ### optimization

      def _restrict(type, predicate)
        operand.restrict(predicate).cached(key_attributes, cache)
      end

    end # class Cached
  end # module Relation 
end # module Bmg
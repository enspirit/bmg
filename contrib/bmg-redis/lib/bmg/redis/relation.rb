module Bmg
  module Redis
    class Relation
      include Bmg::Relation

      DEFAULT_OPTIONS = {
        serializer: :marshal
      }

      def initialize(type, options)
        @type = type
        @options = DEFAULT_OPTIONS.merge(options)

        serializer!
        candidate_key!
      end
      attr_accessor :type

      attr_reader :options
      protected :options

      def each
        return to_enum unless block_given?

        redis.scan_each(match: "#{key_prefix}:*") do |key|
          tuple_str = redis.get(key)
          tuple = serializer.deserialize(tuple_str)
          yield(tuple)
        end
      end

    ### optimization

      def _restrict(type, predicate)
        return super unless key = full_and_only_key?(predicate)

        if tuple_str = redis.get(extract_key(key))
          tuple = serializer.deserialize(tuple_str)
          Bmg::Relation.new([tuple], type)
        else
          Bmg::Relation.empty
        end
      end

    ###

      def insert(tuple_or_tuples)
        case tuple_or_tuples
        when Hash
          key = extract_key(tuple_or_tuples)
          serialized = serializer.serialize(tuple_or_tuples)
          redis.set(key, serialized)
        else
          tuple_or_tuples.each do |tuple|
            insert(tuple)
          end
        end
        self
      end

      def update(updating, predicate = Predicate.tautology)
        restrict(predicate).each do |tuple|
          insert(tuple.merge(updating))
        end
        self
      end

      def delete(predicate = Predicate.tautology)
        keys = self
          .each
          .select{|tuple| predicate.call(tuple) }
          .map{|tuple| extract_key(tuple) }

        redis.del(*keys)

        self
      end

    private

      def serializer
        @serializer ||= begin
          case s = options[:serializer] || :marshal
          when :marshal
            Serializer::Marshal.new
          when :json
            Serializer::Json.new
          when Serializer
            s
          else
            raise Bmg::Error, "Unknown serializer `#{s}`"
          end
        end
      end
      alias :serializer! :serializer

      def candidate_key
        @candidate_key ||= begin
          raise Bmg::Error, "A key must be provided" unless type.knows_keys?
          type.keys.first
        end
      end
      alias :candidate_key! :candidate_key

      def redis
        options[:redis]
      end

      def key_prefix
        options[:key_prefix] || "bmg"
      end

      def full_and_only_key?(predicate)
        h = begin
          predicate.to_hash
        rescue ArgumentError
          return false
        end

        return false unless h.keys == candidate_key
        return false unless candidate_key.all?{|k|
          h[k].is_a?(String) || h[k].is_a?(Integer)
        }

        h
      end

      def extract_key(tuple)
        key = candidate_key
        key = TupleAlgebra.project(tuple, key)
        key = serializer.serialize(key)
        "#{key_prefix}:#{key}"
      end

    end # class Relation
  end # module Redis
end # module Bmg

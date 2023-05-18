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

        redis_key = extract_key(key)
        if tuple_str = redis.get(redis_key)
          tuple = serializer.deserialize(tuple_str)
          Singleton.new(type, self, tuple)
        else
          Bmg::Relation.empty
        end
      end

    ###

      def insert(tuple_or_tuples)
        case tuple_or_tuples
        when Hash
          insert_one(tuple_or_tuples, redis)
        else
          redis.multi do |transaction|
            tuple_or_tuples.each do |tuple|
              insert_one(tuple, transaction)
            end
          end
        end
        self
      end

      def insert_one(tuple, redis)
        key = extract_key(tuple)
        serialized = serializer.serialize(tuple)
        redis.set(key, serialized)
        self
      end
      private :insert_one

      def update(updating, predicate = Predicate.tautology)
        updates = restrict(predicate).map do |tuple|
          tuple.merge(updating)
        end
        insert(updates)
      end

      def delete(predicate = Predicate.tautology)
        keys = restrict(predicate).each.map{|t| extract_key(t) }
        redis.multi do |transaction|
          keys.each_slice(1000) do |slice|
            transaction.del(*slice)
          end
        end
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
        key = key.to_json
        "#{key_prefix}:#{key}"
      end

    end # class Relation
  end # module Redis
end # module Bmg

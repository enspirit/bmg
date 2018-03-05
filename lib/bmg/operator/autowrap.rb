module Bmg
  module Operator
    #
    # Autowrap operator.
    #
    # Autowrap can be used to structure tuples ala Tutorial D' wrap, but it works
    # with conventions instead of explicit wrapping, and supports multiple levels
    # or wrapping.
    #
    # Examples:
    #
    #   [{ a: 1, b_x: 2, b_y: 3 }]     => [{ a: 1, b: { x: 2, y: 3 } }]
    #   [{ a: 1, b_x_y: 2, b_x_z: 3 }] => [{ a: 1, b: { x: { y: 2, z: 3 } } }]
    #
    # Autowrap supports the following options:
    #
    # - `postprocessor: :nil|:none|:delete|Hash|Proc` see NoLeftJoinNoise
    # - `split: String` the seperator to use to split keys, defaults to `_`
    #
    class Autowrap
      include Operator

      DEFAULT_OPTIONS = {
        :postprocessor => :none,
        :split => "_"
      }

      def initialize(type, operand, options = {})
        @type = type
        @operand = operand
        @options = DEFAULT_OPTIONS.merge(options)
        @options[:postprocessor] = NoLeftJoinNoise.new(@options[:postprocessor])
      end

    private

      attr_reader :type, :operand, :options

    public

      def each
        @operand.each do |tuple|
          yield autowrap(tuple)
        end
      end

    private

      def autowrap(tuple)
        separator = @options[:split]
        autowrapped = tuple.each_with_object({}){|(k,v),h|
          parts = k.to_s.split(separator).map(&:to_sym)
          sub = h
          parts[0...-1].each do |part|
            sub = (sub[part] ||= {})
          end
          sub[parts[-1]] = v
          h
        }
        autowrapped = postprocessor.call(autowrapped)
        autowrapped
      end

      def postprocessor
        @options[:postprocessor]
      end

      #
      # Removes the noise generated by left joins that were not join.
      #
      # i.e. x is removed in { x: { id: nil, name: nil, ... } }
      #
      # Supported heuristics are:
      #
      # - nil:    { x: { id: nil, name: nil, ... } } => { x: nil }
      # - delete: { x: { id: nil, name: nil, ... } } => { }
      # - none:   { x: { id: nil, name: nil, ... } } => { x: { id: nil, name: nil, ... } }
      # - a Hash, specifying a specific heuristic by tuple attribute
      # - a Proc, `->(tuple,key){ ... }` that affects the tuple manually
      #
      class NoLeftJoinNoise

        REMOVERS = {
          nil:    ->(t,k){ t[k] = nil  },
          delete: ->(t,k){ t.delete(k) },
          none:   ->(t,k){ t           }
        }

        def initialize(remover)
          @remover = case remover
          when NilClass then REMOVERS[:none]
          when Proc     then remover
          when Symbol   then REMOVERS[remover]
          when Hash     then ->(t,k){ REMOVERS[remover[k] || :none].call(t,k) }
          else
            raise "Invalid remover `#{remover}`"
          end
        end

        def call(tuple)
          tuple.each_key do |k|
            @remover.call(tuple, k) if tuple[k].is_a?(Hash) && all_nil?(tuple[k])
          end
          tuple
        end

        def all_nil?(tuple)
          return false unless tuple.is_a?(Hash)
          tuple.all?{|(k,v)| v.nil? || all_nil?(tuple[k]) }
        end

      end # NoLeftJoinNoise

    end # class Autowrap
  end # module Operator
end # module Bmg

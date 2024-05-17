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
      include Operator::Unary

      DEFAULT_OPTIONS = {
        :postprocessor => :none,
        :postprocessor_condition => :all,
        :split => "_"
      }

      class << self
        def separator(options)
          options[:split] || DEFAULT_OPTIONS[:split]
        end
      end

      def initialize(type, operand, options = {})
        @type = type
        @operand = operand
        @original_options = options
        @options = normalize_options(options)
      end

    private

      attr_reader :options

    public

      def same_options?(opts)
        normalize_options(opts) == options
      end

      def each
        return to_enum unless block_given?
        @operand.each do |tuple|
          yield autowrap_tuple(tuple)
        end
      end

      def to_ast
        [ :autowrap, operand.to_ast, @original_options.dup ]
      end

    public ### for internal reasons

      def _count
        operand._count
      end

    protected ### optimization

      def _allbut(type, butlist)
        new_roots = wrapped_roots!
        separator = @options[:split]
        down = operand.type.attrlist!.select { |attr|
          root = attr.to_s.split(separator).map(&:to_sym).first
          butlist.include?(root)
        }
        r = operand.allbut(down)
        r = r.autowrap(options) unless (butlist & new_roots == new_roots)
        r
      rescue UnknownAttributesError
        super
      end

      def _autowrap(type, opts)
        if same_options?(opts)
          self
        else
          super
        end
      end

      def _join(type, right, on)
        if _join_optimizable?(type, right, on)
          operand.join(right, on).autowrap(options)
        else
          super
        end
      end

      def _joined_with(type, right, on)
        if _join_optimizable?(type, right, on)
          right.join(operand, on).autowrap(options)
        else
          super
        end
      end

      def _join_optimizable?(type, right, on)
        # 1. Can't optimize if wrapped roots are used in join clause
        # 2. Can't optimize if other attributes would be autowrapped
        (wrapped_roots! & on).empty? && wrapped_roots_of!(right, options).empty?
      rescue UnknownAttributesError
        false
      end

      def _matching(type, right, on)
        if (wrapped_roots! & on).empty?
          operand.matching(right, on).autowrap(options)
        else
          super
        end
      rescue UnknownAttributesError
        super
      end

      def _page(type, ordering, page_index, opts)
        attrs = ordering.map{|(a,d)| a }
        if (wrapped_roots! & attrs).empty?
          operand.page(ordering, page_index, opts).autowrap(options)
        else
          super
        end
      rescue UnsupportedError, UnknownAttributesError
        super
      end

      def _project(type, attrlist)
        separator = @options[:split]
        to_keep = operand.type.attrlist!.select { |attr|
          root = attr.to_s.split(separator).map(&:to_sym).first
          attrlist.include?(root)
        }
        operand.project(to_keep).autowrap(options)
      rescue UnknownAttributesError
        super
      end

      def _rename(type, renaming)
        # 1. Can't optimize if renaming applies to a wrapped one
        return super unless (wrapped_roots! & renaming.keys).empty?

        # 2. Can't optimize if new attributes would be autowrapped
        new_roots = Support.wrapped_roots(renaming.values, options[:split])
        return super unless new_roots.empty?

        operand.rename(renaming).autowrap(options)
      rescue UnknownAttributesError
        super
      end

      def _restrict(type, predicate)
        vars = predicate.free_variables
        if (wrapped_roots! & vars).empty?
          operand.restrict(predicate).autowrap(options)
        else
          super
        end
      rescue UnknownAttributesError
        super
      end

    protected ### inspect

      def args
        [ options ]
      end

    private

      def wrapped_roots!
        @wrapped_roots ||= wrapped_roots_of!(operand, options)
      end

      def wrapped_roots_of!(r, opts)
        raise UnknownAttributesError unless r.type.knows_attrlist?

        Support.wrapped_roots(r.type.to_attrlist, opts[:split])
      end

      def normalize_options(options)
        opts = DEFAULT_OPTIONS.merge(options)
        opts[:postprocessor] = NoLeftJoinNoise.new(opts[:postprocessor], opts[:postprocessor_condition])
        opts
      end

      def autowrap_tuple(tuple)
        separator = @options[:split]
        autowrapped = tuple.each_with_object({}){|(k,v),h|
          parts = k.to_s.split(separator).map(&:to_sym)
          sub = h
          parts[0...-1].each do |part|
            sub = (sub[part] ||= {})
          end
          unless sub.is_a?(Hash)
            raise Bmg::Error, "Autowrap conflict on attribute `#{parts[-2]}`"
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
          nil:       ->(t,k){ t[k] = nil  },
          delete:    ->(t,k){ t.delete(k) },
          none:      ->(t,k){ t           }
        }

        def self.new(remover, remover_condition = :all)
          return remover if remover.is_a?(NoLeftJoinNoise)
          super
        end

        def initialize(remover, remover_condition = :all)
          @remover_to_s = remover
          @remover = case remover
          when NilClass then REMOVERS[:none]
          when Proc     then remover
          when Symbol   then REMOVERS[remover]
          when Hash     then ->(t,k){ REMOVERS[remover[k] || :none].call(t,k) }
          else
            raise "Invalid remover `#{remover}`"
          end
          @remover_condition = case remover_condition
          when :all then ->(tuple){ all_nil?(tuple) }
          when :id  then ->(tuple){ id_nil?(tuple) }
          else
            raise "Invalid remover condition `#{remover_condition}`"
          end
        end
        attr_reader :remover

        def call(tuple)
          tuple.each_key do |k|
            call(tuple[k]) if tuple[k].is_a?(Hash)
            @remover.call(tuple, k) if tuple[k].is_a?(Hash) && @remover_condition.call(tuple[k])
          end
          tuple
        end

        def all_nil?(tuple)
          return false unless tuple.is_a?(Hash)

          tuple.all?{|(k,v)| v.nil? || all_nil?(tuple[k]) }
        end

        def id_nil?(tuple)
          return false unless tuple.is_a?(Hash)

          tuple[:id].nil?
        end

        def inspect
          @remover_to_s.inspect
        end
        alias :to_s :inspect

        def hash
          remover.hash
        end

        def ==(other)
          other.is_a?(NoLeftJoinNoise) && remover.eql?(other.remover)
        end

      end # NoLeftJoinNoise

      module Support

        def wrapped_roots(attrlist, split_symbol)
          attrlist.map{|a|
            split = a.to_s.split(split_symbol)
            split.size == 1 ? nil : split[0]
          }.compact.uniq.map(&:to_sym)
        end
        module_function :wrapped_roots

      end # module Support

    end # class Autowrap
  end # module Operator
end # module Bmg

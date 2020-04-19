module Bmg
  module Operator
    #
    # Image operator.
    #
    # Extends each tuple with its image in right.
    #
    class Image
      include Operator::Binary

      DEFAULT_OPTIONS = {

        # Whether we need to convert each image as an Array,
        # instead of keeping a Relation instance
        array: false,

        # The strategy to use for actual image algorithm
        # strategy: :refilter_right

      }

      def initialize(type, left, right, as, on, options = {})
        @type = type
        @left = left
        @right = right
        @as = as
        @on = on
        @options = DEFAULT_OPTIONS.merge(options)
      end

    private

      attr_reader :as, :on, :options

    public

      def each(*args, &bl)
        (options[:jit_optimized] ? self : jit_optimize)._each(*args, &bl)
      end

      def to_ast
        [ :image, left.to_ast, right.to_ast, as, on, options.dup ]
      end

    protected

      def _each(*args, &bl)
        case s = options[:strategy]
        when :none, NilClass then _each_none(*args, &bl)
        when :refilter_right then _each_refilter_right(*args, &bl)
        else
          raise ArgumentError, "Unknown strategy `#{s}`"
        end
      end

      def _each_none(*args, &bl)
        left_rel, right_rel = self.left, self.right
        _each_implem(left_rel, right_rel, *args, &bl)
      end

      def _each_refilter_right(*args, &bl)
        left_rel, right_rel = self.left, self.right

        # find matching keys on left and rebind the right
        # placeholder to them
        values = left_rel.map{|t| t[on.first] }
        placeholder = options[:refilter_right][:placeholder]
        right_rel = right_rel.bind(placeholder => values)

        _each_implem(left_rel, right_rel, *args, &bl)
      end

      def _each_implem(left_rel, right_rel, *args)
        # build right index
        index = build_right_index(right_rel)

        # each left with image from right index
        left_rel.each do |tuple|
          key = tuple_project(tuple, on)
          image = index[key] || (options[:array] ? [] : empty_image)
          yield tuple.merge(as => image)
        end
      end

      def build_right_index(right)
        index = Hash.new{|h,k| h[k] = empty_image }
        right.each_with_object(index) do |t, index|
          key = tuple_project(t, on)
          index[key].operand << tuple_image(t, on)
        end
        if options[:array]
          index = index.each_with_object({}) do |(k,v),ix|
            ix[k] = v.to_a
          end
        end
        index
      end

    protected ### jit_optimization

      def jit_optimize
        case s = options[:strategy]
        when :none, NilClass then jit_none
        when :refilter_right then jit_refilter_right
        else
          raise ArgumentError, "Unknown strategy `#{s}`"
        end
      end

      def jit_none
        Image.new(
          type,
          left,
          right,
          as,
          on,
          options.merge(jit_optimized: true))
      end

      def jit_refilter_right
        ltc = left.type.predicate.constants
        rtc = right.type.predicate.constants
        jit_allbut, jit_on = on.partition{|attr|
          ltc.has_key?(attr) && rtc.has_key?(attr) && ltc[attr] == rtc[attr]
        }
        if jit_on.size == 1
          p = Predicate.placeholder
          Image.new(
            type,
            left.materialize,
            right.restrict(Predicate.in(jit_on.first, p)).allbut(jit_allbut),
            as,
            jit_on,
            options.merge(jit_optimized: true, refilter_right: { placeholder: p }))
        else
          Image.new(
            type,
            left,
            right.allbut(jit_allbut),
            as,
            jit_on,
            options.merge(jit_optimized: true, strategy: :none))
        end
      end

    protected ### optimization

      def _page(type, ordering, page_index, opts)
        if ordering.map{|(k,v)| k}.include?(as)
          super
        else
          left
            .page(ordering, page_index, opts)
            .image(right, as, on, options)
        end
      end

      def _restrict(type, predicate)
        on_as, rest = predicate.and_split([as])
        if rest.tautology?
          # push none situation: on_as is still the full predicate
          super
        else
          # rest makes no reference to `as` and can be pushed
          # down...
          new_left = left.restrict(rest)

          # regarding right... rest possibly makes references to the
          # join key, but also to left attributes... let split again
          # on the join key attributes, to try to remove spurious
          # attributes for right...
          on_on_and_more, left_only = rest.and_split(on)

          # it's not guaranteed! let now check whether the split led
          # to a situation where the predicate on `on` attributes
          # actually refers to no other ones...
          if !on_on_and_more.tautology? and (on_on_and_more.free_variables - on).empty?
            new_right = right.restrict(on_on_and_more)
          else
            new_right = right
          end

          # This is the image itself
          opt = new_left.image(new_right, as, on, options)

          # finaly, it still needs to be kept on the final node
          opt = opt.restrict(on_as)

          opt
        end
      rescue Predicate::NotSupportedError
        super
      end

    protected ### inspect

      def args
        [ as, on, options ]
      end

    private

      def tuple_project(tuple, on)
        TupleAlgebra.project(tuple, on)
      end

      def tuple_image(tuple, on)
        TupleAlgebra.allbut(tuple, on)
      end

      def image_type
        type[as]
      end

      def empty_image
        Relation::InMemory.new(image_type, Set.new)
      end

    public

      # Returns a String representing the query plan
      def debug(max_level = nil, on = STDERR)
        on.puts(options[:jit_optimized] ? self : jit_optimize)
        self
      end

    end # class Project
  end # module Operator
end # module Bmg

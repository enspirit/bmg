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
        array: false

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

      def each
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
        left.each do |tuple|
          key = tuple_project(tuple, on)
          image = index[key] || (options[:array] ? [] : empty_image)
          yield tuple.merge(as => image)
        end
      end

      def to_ast
        [ :image, left.to_ast, right.to_ast, as, on, options.dup ]
      end

    protected ### optimization

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

    end # class Project
  end # module Operator
end # module Bmg

module Bmg
  module Operator
    #
    # Image operator.
    #
    # Extends each tuple with its image in right.
    #
    class Image
      include Operator

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
      attr_reader :type

    private

      attr_reader :left, :right, :as, :on, :options

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
        if on_as == predicate
          super
        else
          shared, left_only = rest.and_split(on)
          new_left  = left.restrict(rest)
          new_right = shared.tautology? ? right : right.restrict(shared)
          opt = new_left.image(new_right, as, on, options)
          opt = opt.restrict(on_as) unless on_as.tautology?
          opt
        end
      rescue Predicate::NotSupportedError
        super
      end

    private

      def tuple_project(tuple, on)
        on.each_with_object({}){|k,t| t[k] = tuple[k] }
      end

      def tuple_image(tuple, on)
        tuple.dup.delete_if{|k,_| on.include?(k) }
      end

      def image_type
        type[as]
      end

      def empty_image
        Leaf.new(image_type, Set.new)
      end

    end # class Project
  end # module Operator
end # module Bmg

module Bmg
  module Ordering

    # Factory over subclasses
    def self.new(arg)
      case arg
      when Ordering
        arg
      when Proc
        Native.new(arg)
      else
        Attributes.new(arg)
      end
    end

    def call(t1, t2)
      comparator.call(t1, t2)
    end

    def to_a
      to_pairs
    end

    def map(*args, &bl)
      to_pairs.map(*args, &bl)
    end

    class Native
      include Ordering

      def initialize(comparator)
        @comparator = comparator
      end
      attr_reader :comparator

      def to_pairs
        raise Bmg::NotSupportedError
      end

    end # class Native

    class Attributes
      include Ordering

      def initialize(attrs)
        @attrs = if attrs.empty?
          []
        elsif attrs.first.is_a?(Symbol)
          attrs.map{|a| [a, :asc] }
        else
          attrs
        end
      end
      attr_reader :attrs

      def comparator
        @comparator ||= ->(t1, t2) { compare_attrs(t1, t2) }
      end

      def to_pairs
        attrs.to_a
      end

    private

      def compare_attrs(t1, t2)
        attrs.each do |(attr,direction)|
          a1, a2 = t1[attr], t2[attr]
          if a1.nil? && a2.nil?
            0
          elsif a1.nil?
            return direction == :desc ? -1 : 1
          elsif a2.nil?
            return direction == :desc ? 1 : -1
          elsif a1.respond_to?(:<=>)
            c = a1 <=> a2
            unless c.nil? || c==0
              return direction == :desc ? -c : c
            end
          end
        end
        0
      end

    end # class Attributes
  end # module Ordering
end # module Bmg

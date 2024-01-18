module Bmg
  class Ordering

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

    def call(t1, t2)
      comparator.call(t1, t2)
    end

    def comparator
      @comparator ||= ->(t1, t2) { compare_attrs(t1, t2) }
    end

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

    def to_a
      attrs.to_a
    end

  end # class Ordering
end # module Bmg

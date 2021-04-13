module Bmg
  class Ordering

    def initialize(attrs)
      @attrs = attrs
    end
    attr_reader :attrs

    def comparator
      ->(t1, t2) {
        attrs.each do |(attr,direction)|
          c = t1[attr] <=> t2[attr]
          return (direction == :desc ? -c : c) unless c==0
        end
        0
      }
    end

  end # class Ordering
end # module Bmg

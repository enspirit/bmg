module Bmg
  class Leaf
    include Relation

    def initialize(type, operand)
      @operand = operand
      @type = type
    end
    attr_reader :type, :operand

  public

    def each(&bl)
      @operand.each(&bl)
    end

    def to_ast
      [:leaf, operand]
    end

  end
end

module Bmg
  class Leaf
    include Relation

    def initialize(operand)
      @operand = operand
    end

  private

    attr_reader :operand

  public

    def each(&bl)
      @operand.each(&bl)
    end

  end
end

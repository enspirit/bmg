module Bmg
  class Leaf
    include Relation

    def initialize(type, operand)
      @operand = operand
      @type = type
    end

  protected

    attr_reader :operand, :type

  public

    def each(&bl)
      @operand.each(&bl)
    end

  end
end

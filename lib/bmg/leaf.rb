module Bmg
  class Leaf
    include Relation

    def initialize(type, operand)
      @operand = operand
      @type = type
    end
    attr_reader :type

  protected

    attr_reader :operand

  public

    def each(&bl)
      @operand.each(&bl)
    end

  end
end

module Bmg
  class Relation
    include Enumerable

    def initialize(operand)
      @operand = operand
    end

    def each(&bl)
      @operand.each(&bl)
    end

    def allbut(butlist = [])
      Relation.new Operator::Allbut.new(@operand, butlist)
    end

    def autowrap(options = {})
      Relation.new Operator::Autowrap.new(@operand, options)
    end

    def autosummarize(by = [], summarization = {})
      Relation.new Operator::Autosummarize.new(@operand, by, summarization)
    end

    def project(attrlist = [])
      Relation.new Operator::Project.new(@operand, attrlist)
    end

    def rename(renaming = {})
      Relation.new Operator::Rename.new(@operand, renaming)
    end

  end # class Relation
end # module Bmg

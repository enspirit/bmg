module Bmg
  module Algebra

    def allbut(butlist = [])
      Operator::Allbut.new(self, butlist)
    end

    def autowrap(options = {})
      Operator::Autowrap.new(self, options)
    end

    def autosummarize(by = [], summarization = {})
      Operator::Autosummarize.new(self, by, summarization)
    end

    def extend(extension = {})
      Operator::Extend.new(self, extension)
    end

    def project(attrlist = [])
      Operator::Project.new(self, attrlist)
    end

    def rename(renaming = {})
      Operator::Rename.new(self, renaming)
    end

    def restrict(predicate)
      Operator::Restrict.new(self, Predicate.coerce(predicate))
    end

    def union(other)
      Operator::Union.new(self, other)
    end

  end # module Algebra
end # module Bmg

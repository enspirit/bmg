module Bmg
  module Algebra

    def allbut(butlist = [])
      _allbut self.type.allbut(butlist), butlist
    end

    def _allbut(type, butlist)
      Operator::Allbut.new(type, self, butlist)
    end
    protected :_allbut

    def autowrap(options = {})
      _autowrap self.type.autowrap(options), options
    end

    def _autowrap(type, options)
      Operator::Autowrap.new(type, self, options)
    end
    protected :_autowrap

    def autosummarize(by = [], summarization = {})
      _autosummarize type = self.type.autosummarize(by, summarization), by, summarization
    end

    def _autosummarize(type, by, summarization)
      Operator::Autosummarize.new(type, self, by, summarization)
    end
    protected :_autosummarize

    def constants(cs = {})
      _constants self.type.constants(cs), cs
    end

    def _constants(type, cs)
      Operator::Constants.new(type, self, cs)
    end
    protected :_constants

    def extend(extension = {})
      _extend self.type.extend(extension), extension
    end

    def _extend(type, extension)
      Operator::Extend.new(type, self, extension)
    end
    protected :_extend

    def image(right, as = :image, on = [], options = {})
      _image self.type.image(right, as, on, options), right, as, on, options
    end

    def _image(type, right, as, on, options)
      Operator::Image.new(type, self, right, as, on, options)
    end
    protected :_image

    def project(attrlist = [])
      _project self.type.project(attrlist), attrlist
    end

    def _project(type, attrlist)
      Operator::Project.new(type, self, attrlist)
    end
    protected :_project

    def rename(renaming = {})
      _rename self.type.rename(renaming), renaming
    end

    def _rename(type, renaming)
      Operator::Rename.new(type, self, renaming)
    end
    protected :_rename

    def restrict(predicate)
      predicate = Predicate.coerce(predicate)
      return self if predicate.tautology?
      _restrict self.type.restrict(predicate), predicate
    end

    def _restrict(type, predicate)
      Operator::Restrict.new(type, self, predicate)
    end
    protected :_restrict

    def union(other, options = {})
      _union self.type.union(other.type), other, options
    end

    def _union(type, other, options)
      Operator::Union.new(type, [self, other], options)
    end
    protected :_union

  end # module Algebra
end # module Bmg

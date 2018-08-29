module Bmg
  module Algebra

    def allbut(butlist = [])
      return self if butlist.empty?
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

    def group(attrs, as = :group, options = {})
      _group self.type.group(attrs, as), attrs, as, options
    end

    def _group(type, attrs, as, options)
      Operator::Group.new(type, self, attrs, as, options)
    end
    protected :_group

    def image(right, as = :image, on = [], options = {})
      _image self.type.image(right.type, as, on, options), right, as, on, options
    end

    def _image(type, right, as, on, options)
      Operator::Image.new(type, self, right, as, on, options)
    end
    protected :_image

    def join(right, on = [])
      _join self.type.join(right.type, on), right, on
    end

    def _join(type, right, on)
      Operator::Join.new(type, self, right, on)
    end
    protected :_join

    def matching(right, on = [])
      _matching self.type.matching(right.type, on), right, on
    end

    def _matching(type, right, on)
      Operator::Matching.new(type, self, right, on)
    end
    protected :_matching

    def not_matching(right, on = [])
      _not_matching self.type.not_matching(right.type, on), right, on
    end

    def _not_matching(type, right, on)
      Operator::NotMatching.new(type, self, right, on)
    end
    protected :_not_matching

    def page(ordering, page_index, options)
      _page self.type.page(ordering, page_index, options), ordering, page_index, options
    end

    def _page(type, ordering, page_index, options)
      Operator::Page.new(type, self, ordering, page_index, options)
    end
    protected :_page

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
      if predicate.tautology?
        self
      else
        type = self.type.restrict(predicate)
        if predicate.contradiction?
          Relation.empty(type)
        else
          begin
            _restrict type, predicate
          rescue Predicate::NotSupportedError
            Operator::Restrict.new(type, self, predicate)
          end
        end
      end
    end

    def _restrict(type, predicate)
      Operator::Restrict.new(type, self, predicate)
    end
    protected :_restrict

    def union(other, options = {})
      return self if other.is_a?(Relation::Empty)
      _union self.type.union(other.type), other, options
    end

    def _union(type, other, options)
      Operator::Union.new(type, [self, other], options)
    end
    protected :_union

    def spied(spy)
      return self if spy.nil?
      Relation::Spied.new(self, spy)
    end

    def unspied
      self
    end

    def materialize
      Relation::Materialized.new(self)
    end

    require_relative 'algebra/shortcuts'
    include Shortcuts
  end # module Algebra
end # module Bmg

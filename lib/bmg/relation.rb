module Bmg
  class Relation
    include Enumerable

    def initialize(operand)
      @operand = operand
    end

    ## Consumption methods

    def each(&bl)
      @operand.each(&bl)
    end

    # Private helper to implement `one` and `one_or_nil`
    def one_or_yield(&bl)
      first = nil
      each do |x|
        raise OneError, "Relation has more than one tuple" unless first.nil?
        first = x
      end
      first.nil? ? bl.call : first
    end
    private :one_or_yield

    # Returns the only tuple that the relation contains.
    # Throws a OneException when there is no tuple or more than one
    def one
      one_or_yield{ raise OneError, "Relation is empty" }
    end

    # Returns the only tuple that the relation contains.
    # Returns nil if the relation is empty.
    # Throws a OneException when the relation contains more than one tuple
    def one_or_nil
      one_or_yield{ nil }
    end

    ## Relational algebra

    def allbut(butlist = [])
      Relation.new Operator::Allbut.new(@operand, butlist)
    end

    def autowrap(options = {})
      Relation.new Operator::Autowrap.new(@operand, options)
    end

    def autosummarize(by = [], summarization = {})
      Relation.new Operator::Autosummarize.new(@operand, by, summarization)
    end

    def extend(extension = {})
      Relation.new Operator::Extend.new(@operand, extension)
    end

    def project(attrlist = [])
      Relation.new Operator::Project.new(@operand, attrlist)
    end

    def rename(renaming = {})
      Relation.new Operator::Rename.new(@operand, renaming)
    end

    def restrict(predicate = Predicate.tautology)
      Relation.new Operator::Restrict.new(@operand, Predicate.coerce(predicate))
    end

    def union(other)
      Relation.new Operator::Union.new(@operand, other)
    end

  end # class Relation
end # module Bmg

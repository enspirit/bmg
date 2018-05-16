module Bmg
  class Type

    def initialize(predicate = Predicate.tautology)
      @predicate = predicate
      raise ArgumentError if @predicate.nil?
    end
    attr_reader :predicate

    ANY = Type.new

    def [](attribute)
      ANY
    end

    def allbut(butlist)
      ANY
    end

    def autowrap(options)
      ANY
    end

    def autosummarize(by, summarization)
      ANY
    end

    def constants(cs)
      Type.new(@predicate & Predicate.eq(cs))
    end

    def extend(extension)
      ANY
    end

    def group(attrs, as)
      ANY
    end

    def image(right, as, on, options)
      ANY
    end

    def matching(right, on)
      ANY
    end

    def page(ordering, page_size, options)
      self
    end

    def project(attrlist)
      ANY
    end

    def rename(renaming)
      Type.new(@predicate.rename(renaming))
    end

    def restrict(predicate)
      Type.new(@predicate & predicate)
    end

    def rxmatch(attrs, matcher, options)
      self
    end

    def union(other)
      Type.new(@predicate | other.predicate)
    end

  end # class Type
end # module Bmg

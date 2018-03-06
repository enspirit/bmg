module Bmg
  class Type

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
      ANY
    end

    def extend(extension)
      ANY
    end

    def image(right, as, on, options)
      ANY
    end

    def project(attrlist)
      ANY
    end

    def rename(renaming)
      ANY
    end

    def restrict(predicate)
      ANY
    end

    def union(other)
      ANY
    end

  end # class Type
end # module Bmg

module Bmg
  module Algebra
    module Shortcuts

      def rxmatch(attrs, matcher, options = {})
        predicate = attrs.inject(Predicate.contradiction){|p,a|
          p | Predicate.match(a, matcher, options)
        }
        self.restrict(predicate)
      end

      def prefix(prefix)
        raise "Attrlist must be known to use `prefix`" unless self.type.knows_attrlist?
        renaming = self.type.to_attrlist.each_with_object({}){|a,r|
          r[a] = :"#{prefix}#{a}"
        }
        self.rename(renaming)
      end

      def suffix(suffix)
        raise "Attrlist must be known to use `suffix`" unless self.type.knows_attrlist?
        renaming = self.type.to_attrlist.each_with_object({}){|a,r|
          r[a] = :"#{a}#{suffix}"
        }
        self.rename(renaming)
      end

    end # module Shortcuts
  end # module Algebra
end # module Bmg

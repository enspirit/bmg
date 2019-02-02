module Bmg
  module Algebra
    module Shortcuts

      def rxmatch(attrs, matcher, options = {})
        predicate = attrs.inject(Predicate.contradiction){|p,a|
          p | Predicate.match(a, matcher, options)
        }
        self.restrict(predicate)
      end

      def prefix(prefix, options = {})
        raise "Attrlist must be known to use `prefix`" unless self.type.knows_attrlist?
        attrs = self.type.to_attrlist
        attrs = attrs - options[:but] if options[:but]
        renaming = Hash[attrs.map{|a| [a, :"#{prefix}#{a}"] }]
        self.rename(renaming)
      end

      def suffix(suffix, options = {})
        raise "Attrlist must be known to use `suffix`" unless self.type.knows_attrlist?
        attrs = self.type.to_attrlist
        attrs = attrs - options[:but] if options[:but]
        renaming = Hash[attrs.map{|a| [a, :"#{a}#{suffix}"] }]
        self.rename(renaming)
      end

      def join(right, on = [])
        return super unless on.is_a?(Hash)
        renaming = on.each_pair.inject({}){|r, (k,v)|
          r.merge(v => k)
        }
        self.join(right.rename(renaming), on.keys)
      end

      def tuple_image(right, as, on, options = {})
        sep = "$#{Kernel.rand(999)}$"
        if options[:out]
          self
            .join(right.prefix(:"#{as}#{sep}", :but => on), on)
            .autowrap(split: sep)
        else
          renaming = Hash[on.map{|a| [a, :"#{as}#{sep}#{a}"]}]
          self
            .rename(renaming)
            .join(right.prefix(:"#{as}#{sep}"), renaming.values)
            .autowrap(split: sep)
        end
      end

    end # module Shortcuts
  end # module Algebra
end # module Bmg

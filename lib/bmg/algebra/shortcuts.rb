module Bmg
  module Algebra
    module Shortcuts

      def where(predicate)
        restrict(predicate)
      end

      def exclude(predicate)
        restrict(!Predicate.coerce(predicate))
      end

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

      def image(right, as = :image, on = [], options = {})
        return super unless on.is_a?(Hash)
        renaming = Hash[on.map{|k,v| [v,k] }]
        self.image(right.rename(renaming), as, on.keys, options)
      end

      def images(rights, on = [], options = {})
        rights.each_pair.inject(self){|memo,(as,right)|
          memo.image(right, as, on, options)
        }
      end

      def join(right, on = [])
        return super unless on.is_a?(Hash)
        renaming = Hash[on.map{|k,v| [v,k] }]
        self.join(right.rename(renaming), on.keys)
      end

      def left_join(right, on = [], *args)
        return super unless on.is_a?(Hash)
        renaming = Hash[on.map{|k,v| [v,k] }]
        self.left_join(right.rename(renaming), on.keys, *args)
      end

      def matching(right, on = [])
        return super unless on.is_a?(Hash)
        renaming = Hash[on.map{|k,v| [v,k] }]
        self.matching(right.rename(renaming), on.keys)
      end

      def not_matching(right, on = [])
        return super unless on.is_a?(Hash)
        renaming = Hash[on.map{|k,v| [v,k] }]
        self.not_matching(right.rename(renaming), on.keys)
      end

      def unwrap(attr)
        super(attr.is_a?(Symbol) ? [attr] : attr)
      end

    end # module Shortcuts
  end # module Algebra
end # module Bmg

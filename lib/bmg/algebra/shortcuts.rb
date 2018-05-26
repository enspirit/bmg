module Bmg
  module Algebra
    module Shortcuts

      def rxmatch(attrs, matcher, options = {})
        predicate = attrs.inject(Predicate.contradiction){|p,a|
          p | Predicate.match(a, matcher, options)
        }
        self.restrict(predicate)
      end

    end # module Shortcuts
  end # module Algebra
end # module Bmg

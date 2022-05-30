module Bmg
  module Sequel
    class PredicateTranslator < Sexpr::Processor
      include ::Predicate::ToSequel::Methods

      def initialize(parent)
        @parent = parent
      end

    public ### Predicate hack

      def on_opaque(sexpr)
        @parent.apply(sexpr.last)
      end

      def on_exists(sexpr)
        @parent.apply(sexpr.last).exists
      end

    end # class PredicateTranslator
  end # module Sequel
end # module Bmg

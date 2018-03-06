module Bmg
  module Sequel
    class Relation
      include Bmg::Relation

      def initialize(type, dataset)
        @type = type
        @dataset = dataset
      end
      attr_reader :type

    protected

      attr_reader :dataset

    public

      def each(&bl)
        @dataset.each(&bl)
      end

    public ### optimization

      def restrict(predicate)
        predicate = Predicate.coerce(predicate)
        type = self.type.restrict(predicate)
        Relation.new type, dataset.where(predicate.to_sequel)
      rescue NotImplementedError, Predicate::NotSupportedError
        super
      end

    end # class Relation
  end # module Operator
end # module Bmg

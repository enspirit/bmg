require 'spec_helper'
module Bmg
  module Relation
    describe Materialized do

      class SourceRel
        include Enumerable

        def initialize
          @called = 0
        end
        attr_reader :called

        def type
          Type::ANY
        end

        def each
          @called += 1
          yield(id: 1)
          yield(id: 2)
        end

      end

      let(:expected) {
        [{id: 1},{id: 2}]
      }

      it 'iterates the source only once' do
        source = SourceRel.new
        materialized = Materialized.new(source)
        expect(source.called).to eql(0)
        expect(materialized.to_a).to eql(expected)
        expect(materialized.to_a).to eql(expected)
        expect(source.called).to eql(1)
      end

    end
  end # module Relation
end # module Bmg

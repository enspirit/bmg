require 'spec_helper'
module Bmg
  module Sequel
    describe Relation do

      let(:suppliers_type) {
        Type::ANY.with_attrlist([:sid, :name, :city, :status])
      }

      context 'starting with a table name' do

        let(:relation) {
          Bmg.sequel(:suppliers, sequel_db, suppliers_type)
        }

        it 'works' do
          expect(relation.to_a.size).to eql(5)
        end

        it 'optimizes restrictions' do
          optimized = relation.restrict(sid: "S1")
          expect(optimized).to be_a(Sequel::Relation)
        end

        it 'supports restriction bindings' do
          p = Predicate.placeholder
          unbound = relation.restrict(sid: p)
          bound = unbound.bind(p => "S1")
          expect(bound.to_a.size).to eql(1)
        end

        it 'supports projections' do
          optimized = relation.restrict(sid: "S1").project([:name])
          expect(optimized).to be_a(Sequel::Relation)
        end

        it 'does not fail when a native predicate is used' do
          optimized = relation.restrict(->(t){ false })
          expect(optimized).to be_a(Operator::Restrict)
          expect(optimized.to_a).to be_empty
        end

      end

      context 'starting with a dataset' do

        let(:relation) {
          Bmg.sequel(sequel_db[:suppliers].from_self, suppliers_type)
        }

        it 'works' do
          expect(relation.to_a.size).to eql(5)
        end

        it 'applies to_self if needed' do
          optimized = relation.restrict(sid: "S1")
          expect(optimized).to be_a(Sequel::Relation)
        end
      end

    end
  end
end

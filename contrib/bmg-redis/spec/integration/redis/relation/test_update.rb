require 'spec_helper'

module Bmg::Redis
  describe Relation, "update" do

    let(:relvar) do
      suppliers_relvar
    end

    context 'without predicate' do
      subject do
        relvar.update(city: 'Brussels')
      end

      it 'returns the relvar itself' do
        expect(subject).to be(relvar)
      end

      it 'updates all tuples' do
        expected = suppliers.map{|s| s.merge(city: 'Brussels') }.to_set
        expect(subject.to_set).to eql(expected)
      end
    end

    context 'with a predicate' do
      subject do
        relvar.update({city: 'Brussels'}, Predicate.neq(sid: 'S1'))
      end

      it 'returns the relvar itself' do
        expect(subject).to be(relvar)
      end

      it 'updates all tuples' do
        expected = suppliers.map{|s|
          s[:sid] == 'S1' ? s : s.merge(city: 'Brussels')
        }.to_set
        expect(subject.to_set).to eql(expected)
      end
    end
  end
end

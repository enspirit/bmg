require 'spec_helper'

module Bmg::Redis
  describe Relation, "delete" do

    let(:relvar) do
      suppliers_relvar
    end

    context 'without predicate' do
      subject do
        relvar.delete
      end

      it 'returns the relvar itself' do
        expect(subject).to be(relvar)
      end

      it 'removes all tuples' do
        expected = [].to_set
        expect(subject.to_set).to eql(expected)
      end
    end

    context 'with a predicate' do
      subject do
        relvar.delete(Predicate.eq(sid: 'S1'))
      end

      it 'returns the relvar itself' do
        expect(subject).to be(relvar)
      end

      it 'removes only that' do
        expected = suppliers.select{|s| s[:sid] != 'S1'}.to_set
        expect(subject.to_set).to eql(expected)
      end
    end
  end
end

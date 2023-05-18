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

      it 'removes all tuples' do
        expect(subject).to be(relvar)
        expected = [].to_set
        expect(subject.to_set).to eql(expected)
      end
    end

    context 'with a predicate' do
      subject do
        relvar.delete(Predicate.eq(sid: 'S1'))
      end

      it 'removes only that' do
        expect(subject).to be(relvar)
        expected = suppliers.select{|s| s[:sid] != 'S1'}.to_set
        expect(subject.to_set).to eql(expected)
      end
    end

    context 'on a very large relation' do
      let(:relvar) do
        large_relvar
      end

      subject do
        relvar.delete(Predicate.gt(id: 100))
      end

      it 'deletes by chunks' do
        expect(relvar.to_a.size).to eql(1000)
        expect(subject).to be(relvar)
        expect(subject.to_a.size).to eql(100)
      end
    end
  end
end

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
  end
end

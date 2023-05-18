require 'spec_helper'

module Bmg::Redis
  describe Relation, "update" do

    let(:relvar) do
      suppliers_relvar
    end

    context 'without predicate' do
      before do
        allow(redis).to receive(:scan_each).and_call_original
      end

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

    context 'with a predicate on a non key' do
      before do
        allow(redis).to receive(:scan_each).and_call_original
      end

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

    context 'with a predicate on a key' do
      before do
        expect(redis).not_to receive(:scan_each)
      end

      subject do
        relvar.update({city: 'Brussels'}, sid: 'S1')
      end

      it 'returns the relvar itself' do
        expect(subject).to be(relvar)
      end

      it 'updates all tuples' do
        subject
        expected = relvar.restrict(sid: 'S1').one
        expect(expected[:city]).to eql('Brussels')
      end
    end

    context 'on a restricted relation' do
      before do
        expect(redis).not_to receive(:scan_each)
      end

      subject do
        relvar.restrict(sid: 'S1').update({city: 'Brussels'})
      end

      it 'updates all tuples' do
        expect(subject).to be_a(Singleton)
        expected = relvar.restrict(sid: 'S1').one
        expect(expected[:city]).to eql('Brussels')
      end
    end
  end
end

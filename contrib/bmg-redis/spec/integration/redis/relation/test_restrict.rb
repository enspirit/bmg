require 'spec_helper'

module Bmg::Redis
  describe Relation, "restrict" do

    let(:relvar) do
      suppliers_relvar
    end

    context 'with a predicate that allows optimizing' do
      before do
        expect(redis).not_to receive(:scan_each)
        allow(redis).to receive(:get).and_call_original
      end

      it 'does optimize' do
        got = relvar.restrict(sid: 'S1').to_a
        expect(got.size).to eql(1)
        expect(got.first).to eql(suppliers.first)
      end

      it 'supports a non-existing key and returns an empty relation' do
        got = relvar.restrict(sid: 'S17').to_a
        expect(got.size).to eql(0)
      end
    end

    context 'with a predicate that does not allow optimizing' do
      before do
        allow(redis).to receive(:scan_each).and_call_original
      end

      it 'does not optimize on non key' do
        got = relvar.restrict(city: 'London').to_a
        expect(got.size).to eql(1)
      end

      it 'does not optimize key + extra' do
        got = relvar.restrict(sid: 'S1', city: 'Paris').to_a
        expect(got.size).to eql(1)
      end
    end

  end
end

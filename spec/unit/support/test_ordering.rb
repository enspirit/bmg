require 'spec_helper'
module Bmg
  describe Ordering do

    let(:ordering) {
      Ordering.new(attrs)
    }

    describe 'new' do
      it 'supports pairs' do
        o = Ordering.new([[:name, :desc],[:id, :asc]])
        expect(o.send(:to_a)).to eql([[:name, :desc],[:id, :asc]])
      end

      it 'supports attribute names' do
        o = Ordering.new([:name, :id])
        expect(o.send(:to_a)).to eql([[:name, :asc],[:id, :asc]])
      end

      it 'supports a comparator' do
        comparator = ->(t1,t2){ 1 }
        o = Ordering.new(comparator)
        expect(o.comparator).to be(comparator)
      end
    end

    context 'when a single attr, asc' do
      let(:attrs) {
        [[:title, :asc]]
      }

      it 'works as expected' do
        expect(ordering.call({title: 'B'}, {title: 'B'}) == 0).to eql(true)
        expect(ordering.call({title: 'A'}, {title: 'B'}) < 0).to eql(true)
        expect(ordering.call({title: 'B'}, {title: 'A'}) > 0).to eql(true)
      end

      it 'supports nil' do
        expect(ordering.call({title: nil}, {title: nil}) == 0).to eql(true)
        expect(ordering.call({title: 'A'}, {title: nil}) < 0).to eql(true)
        expect(ordering.call({title: nil}, {title: 'A'}) > 0).to eql(true)
      end
    end

    context 'when a single attr, desc' do
      let(:attrs) {
        [[:title, :desc]]
      }

      it 'works as expected' do
        expect(ordering.call({title: 'B'}, {title: 'B'}) == 0).to eql(true)
        expect(ordering.call({title: 'A'}, {title: 'B'}) > 0).to eql(true)
        expect(ordering.call({title: 'B'}, {title: 'A'}) < 0).to eql(true)
      end

      it 'supports nil' do
        expect(ordering.call({title: nil}, {title: nil}) == 0).to eql(true)
        expect(ordering.call({title: 'A'}, {title: nil}) > 0).to eql(true)
        expect(ordering.call({title: nil}, {title: 'A'}) < 0).to eql(true)
      end
    end

    context 'when non comparable attrs' do
      let(:attrs) {
        [[:error, :desc]]
      }

      it 'works as expected' do
        expect(ordering.call({error: Object.new}, {error: Object.new}) == 0).to eql(true)
      end
    end

    context 'with a comparator' do
      let(:attrs) {
        ->(t1, t2){ t1[:title] <=> t2[:title] }
      }

      it 'works as expected' do
        expect(ordering.call({title: 'B'}, {title: 'B'}) == 0).to eql(true)
        expect(ordering.call({title: 'A'}, {title: 'B'}) < 0).to eql(true)
        expect(ordering.call({title: 'B'}, {title: 'A'}) > 0).to eql(true)
      end
    end

  end
end

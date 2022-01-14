require 'spec_helper'
module Bmg
  describe Ordering do
    let(:ordering) {
      Ordering.new(attrs)
    }

    context 'when a single attr, asc' do
      let(:attrs) {
        [[:title, :asc]]
      }

      it 'works as expected' do
        expect(ordering.compare_attrs({title: 'B'}, {title: 'B'}) == 0).to eql(true)
        expect(ordering.compare_attrs({title: 'A'}, {title: 'B'}) < 0).to eql(true)
        expect(ordering.compare_attrs({title: 'B'}, {title: 'A'}) > 0).to eql(true)
      end

      it 'supports nil' do
        expect(ordering.compare_attrs({title: nil}, {title: nil}) == 0).to eql(true)
        expect(ordering.compare_attrs({title: 'A'}, {title: nil}) < 0).to eql(true)
        expect(ordering.compare_attrs({title: nil}, {title: 'A'}) > 0).to eql(true)
      end
    end

    context 'when a single attr, desc' do
      let(:attrs) {
        [[:title, :desc]]
      }

      it 'works as expected' do
        expect(ordering.compare_attrs({title: 'B'}, {title: 'B'}) == 0).to eql(true)
        expect(ordering.compare_attrs({title: 'A'}, {title: 'B'}) > 0).to eql(true)
        expect(ordering.compare_attrs({title: 'B'}, {title: 'A'}) < 0).to eql(true)
      end

      it 'supports nil' do
        expect(ordering.compare_attrs({title: nil}, {title: nil}) == 0).to eql(true)
        expect(ordering.compare_attrs({title: 'A'}, {title: nil}) > 0).to eql(true)
        expect(ordering.compare_attrs({title: nil}, {title: 'A'}) < 0).to eql(true)
      end
    end

    context 'when non comparable attrs' do
      let(:attrs) {
        [[:error, :desc]]
      }

      it 'works as expected' do
        expect(ordering.compare_attrs({error: Object.new}, {error: Object.new}) == 0).to eql(true)
      end
    end

  end
end

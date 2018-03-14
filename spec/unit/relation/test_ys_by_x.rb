require 'spec_helper'
module Bmg
  describe Relation, "ys_by_x" do

    let(:relation) {
      Leaf.new Type::ANY, [
        { a: 1, b: 1, order: 5 },
        { a: 1, b: 2, order: 2 },
        { a: 1, b: 3, order: 3 },
        { a: 2, b: 1, order: 1 },
        { a: 1, b: 2, order: 1 }
      ]
    }    

    subject{ relation.ys_by_x(:b, :a, options) }

    context 'without ordering nor distinct' do
      let(:options){ {} }

      it 'works as expected' do
        expect(subject).to eql({
          1 => [1, 2, 3, 2],
          2 => [1]
        })
      end
    end

    context 'with an ordering' do
      let(:options){ { :order => :order } }

      it 'works as expected' do
        expect(subject).to eql({
          1 => [2, 2, 3, 1],
          2 => [1]
        })
      end
    end

    context 'with an ordering and :distinct' do
      let(:options){ { :order => :order, :distinct => true } }

      it 'works as expected' do
        expect(subject).to eql({
          1 => [2, 3, 1],
          2 => [1]
        })
      end
    end

  end
end
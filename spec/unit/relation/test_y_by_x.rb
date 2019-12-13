require 'spec_helper'
module Bmg
  describe Relation, "y_by_x" do

    let(:relation) {
      Relation.new [
        { a: 1, b: 1, order: 5 },
        { a: 1, b: 2, order: 2 },
        { a: 1, b: 3, order: 3 },
        { a: 2, b: 1, order: 1 },
        { a: 1, b: 2, order: 1 }
      ]
    }

    subject{ relation.y_by_x(:b, :a, options) }

    context 'without ordering nor distinct, it takes the last value seen' do
      let(:options){ {} }

      it 'works as expected' do
        expect(subject).to eql({
          1 => 2,
          2 => 1
        })
      end
    end

  end
end

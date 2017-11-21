require 'spec_helper'
module Bmg
  describe Relation do

    shared_examples_for "an operator method" do

      it 'returns a relation' do
        expect(subject).to be_a(Relation)
      end

    end

    describe 'autowrap' do
      let(:relation) {
        Relation.new([
          { a: 1, b_x: 2, b_y: 3 },
          { a: 2, b_x: 4, b_y: 1 }
        ])        
      }

      subject {
        relation.autowrap
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1, b: { x: 2, y: 3 } },
          { a: 2, b: { x: 4, y: 1 } }
        ])
      end

      it 'passes the options' do
        expect(relation.autowrap(split: ".").to_a).to eql([
          { a: 1, b_x: 2, b_y: 3 },
          { a: 2, b_x: 4, b_y: 1 }
        ])
      end
    end

  end # describe Relation
end # module Bmg
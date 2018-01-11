require 'spec_helper'
module Bmg
  describe Relation do

    shared_examples_for "an operator method" do

      it 'returns a relation' do
        expect(subject).to be_a(Relation)
      end

    end

    describe 'allbut' do
      let(:relation) {
        Relation.new([
          { a: 1, b: 2 },
          { a: 1, b: 4 },
          { a: 3, b: 4 }
        ])
      }

      subject {
        relation.allbut([:b])
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1 },
          { a: 3 }
        ])
      end
    end

    describe 'autosummarize' do
      let(:relation) {
        Relation.new([
          { a: 1, x: 2 },
          { a: 1, x: 4 }
        ])
      }

      subject {
        relation.autosummarize([:a], x: Operator::Autosummarize::DistinctList.new)
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1, x: [2, 4] }
        ])
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

    describe 'extend' do
      let(:relation) {
        Relation.new([
          { a: 1, b: 2 },
          { a: 1, b: 4 },
          { a: 3, b: 4 }
        ])
      }

      subject {
        relation.extend(c: ->(t){ t[:a] + t[:b] })
      }

      it_behaves_like "an operator method"

      it 'returns the expected result' do
        expect(subject.to_a).to eql([
          { a: 1, b: 2, c: 3 },
          { a: 1, b: 4, c: 5 },
          { a: 3, b: 4, c: 7 }
        ])
      end
    end

    describe 'project' do
      let(:relation) {
        Relation.new([
          { a: 1, b: 2 },
          { a: 1, b: 4 },
          { a: 3, b: 4 }
        ])
      }

      subject {
        relation.project([:b])
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { b: 2 },
          { b: 4 }
        ])
      end
    end

    describe 'rename' do
      let(:relation) {
        Relation.new([
          { a: 1, b: 2 },
          { a: 2, b: 4 }
        ])
      }

      subject {
        relation.rename(b: :c)
      }

      it_behaves_like "an operator method"

      it 'returns the exected result' do
        expect(subject.to_a).to eql([
          { a: 1, c: 2 },
          { a: 2, c: 4 }
        ])
      end
    end

  end # describe Relation
end # module Bmg

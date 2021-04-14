require 'spec_helper'
module Bmg
  describe "allbut optimization" do

    let(:relation) {
      Relation.new([
        { a: 1,  b: 2, c: 3 },
        { a: 11, b: 2, c: 33 }
      ])
    }

    context 'allbut on empty butlist' do
      subject{
        relation.allbut([])
      }

      it 'returns the operand itself' do
        expect(subject).to be(relation)
      end
    end

    context "allbut.restrict" do

      let(:predicate) {
        Predicate.gt(:a, 10)
      }

      let(:allbuted){ [:b] }

      subject{
        relation.allbut(allbuted).restrict(predicate)
      }

      it 'optimizes by pushing the restriction down' do
        expect(subject).to be_a(Operator::Allbut)
        expect(subject.send(:butlist)).to be(allbuted)
        expect(operand).to be_a(Operator::Restrict)
        expect(operand.send(:predicate)).to be(predicate)
      end

    end

    context "allbut.allbut" do

      context 'when butlist are disjoint' do
        subject{
          relation.allbut([:a]).allbut([:b])
        }

        it 'optimizes by unioning butlists' do
          expect(subject).to be_a(Operator::Allbut)
          expect(subject.send(:butlist)).to eql([:a, :b])
          expect(operand).to be(relation)
        end
      end

      context 'when butlist are not disjoint (make no sense, but ok)' do
        subject{
          relation.allbut([:a]).allbut([:b, :a])
        }

        it 'optimizes by unioning butlists' do
          expect(subject).to be_a(Operator::Allbut)
          expect(subject.send(:butlist)).to eql([:a, :b])
          expect(operand).to be(relation)
        end
      end

    end
  end
end

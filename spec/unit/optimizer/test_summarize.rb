require 'spec_helper'
module Bmg
  describe "summarize optimization" do

    context "summarize.restrict" do
      subject {
        Relation.new([
          { a: 1,  b: 2 },
          { a: 11, b: 2 }
        ]).summarize(by, sums).restrict(predicate)
      }

      context 'when no optimization is possible' do
        let(:by) {
          [:a]
        }
        let(:sums) {
          {:b => :sum}
        }
        let(:predicate) {
          Predicate.gt(:b, 100)
        }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Restrict)
          expect(operand).to be_a(Operator::Summarize)
          expect(subject.send(:predicate)).to eql(predicate)
        end
      end

      context 'when predicate is fully on by' do
        let(:by) {
          [:a]
        }
        let(:sums) {
          {:b => :sum}
        }
        let(:predicate) {
          Predicate.eq(:a, 1)
        }

        it 'pushes restrict down the tree' do
          expect(subject).to be_a(Operator::Summarize)
          expect(operand).to be_a(Operator::Restrict)
          expect(operand.send(:predicate)).to eql(predicate)
        end
      end

      context 'when predicate is on both' do
        let(:by) {
          [:a]
        }
        let(:sums) {
          {:b => :sum}
        }
        let(:p1) {
          Predicate.eq(:a, 1)
        }
        let(:p2) {
          Predicate.lt(:b, 2)
        }
        let(:predicate) {
          p1 & p2
        }

        it 'splits the predicate' do
          expect(subject).to be_a(Operator::Restrict)
          expect(subject.send(:predicate)).to eql(p2)
          expect(operand).to be_a(Operator::Summarize)
          expect(operand.send(:operand)).to be_a(Operator::Restrict)
          expect(operand.send(:operand).send(:predicate)).to eql(p1)
        end
      end

      context "when predicate is on both but can't be split" do
        let(:by) {
          [:a]
        }
        let(:sums) {
          {:b => :sum}
        }
        let(:p1) {
          Predicate.eq(:a, 1)
        }
        let(:p2) {
          Predicate.lt(:b, 2)
        }
        let(:predicate) {
          p1 | p2
        }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Restrict)
          expect(operand).to be_a(Operator::Summarize)
          expect(subject.send(:predicate)).to eql(predicate)
        end
      end
    end
  end
end

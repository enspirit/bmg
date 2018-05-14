require 'spec_helper'
module Bmg
  describe "matching optimization" do

    context "matching.restrict" do
      let(:left_data) {
        [
          { a: 1, b: 2 },
          { a: 3, b: 4 }
        ]
      }

      let(:left) {
        Relation.new(left_data)
      }

      let(:right_data) {
        [
          { a: 1, c: 4 },
          { a: 1, c: 5 }
        ]
      }

      let(:right) {
        Relation.new(right_data)
      }

      subject{
        left.matching(right, [:a]).restrict(predicate)
      }

      context 'when restriction does not touch the shared attributes' do
        let(:predicate) {
          Predicate.eq(b: 2)
        }

        it 'optimizes by pushing the restriction down' do
          expect(subject).to be_a(Operator::Matching)
          expect(left_operand).to be_a(Operator::Restrict)
          expect(left_operand.send(:predicate)).to eql(predicate)
          expect(right_operand).to be_a(Relation::InMemory)
        end
      end

      context 'when predicate cannot be split' do
        let(:predicate) {
          Predicate.native(->(t){ false })
        }

        it 'does not optimize at all' do
          expect(subject).to be_a(Operator::Restrict)
          expect(operand).to be_a(Operator::Matching)
        end
      end

      context 'when restriction touches all shared attributes' do
        let(:predicate) {
          Predicate.eq(a: 1)
        }

        it 'optimizes both sides' do
          expect(subject).to be_a(Operator::Matching)
          expect(left_operand).to be_a(Operator::Restrict)
          expect(left_operand.send(:predicate)).to eql(predicate)
          expect(right_operand).to be_a(Operator::Restrict)
          expect(right_operand.send(:predicate)).to eql(predicate)
        end
      end

      context 'when restriction touches all attributes and can still be optimized' do
        let(:predicate) {
          Predicate.eq(a: 1, b: 2)
        }

        it 'optimizes both sides' do
          expect(subject).to be_a(Operator::Matching)
          expect(left_operand).to be_a(Operator::Restrict)
          expect(predicate_of(left_operand)).to eql(predicate)
          expect(right_operand).to be_a(Operator::Restrict)
          expect(predicate_of(right_operand)).to eql(Predicate.eq(a: 1))
        end
      end

    end

  end
end

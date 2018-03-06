require 'spec_helper'
module Bmg
  describe "union optimization" do

    context "union.restrict" do
      let(:predicate) {
        Predicate.gt(:a, 10)
      }

      let(:left) {
        Relation.new([
          { a: 1 },
        ])
      }

      let(:right) {
        Relation.new([
          { a: 2 },
        ])
      }

      subject{
        left.union(right).restrict(predicate)
      }

      let(:left_operand) {
        subject.send(:left)
      }

      let(:right_operand) {
        subject.send(:right)
      }

      it 'works' do
        expect(subject).to be_a(Operator::Union)
        expect(left_operand).to be_a(Operator::Restrict)
        expect(left_operand.send(:predicate)).to be(predicate)
        expect(right_operand).to be_a(Operator::Restrict)
        expect(right_operand.send(:predicate)).to be(predicate)
      end
    end

  end
end

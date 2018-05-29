require 'spec_helper'
module Bmg
  describe "not_matching optimization" do

    context "not_matching.restrict" do
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
        left.not_matching(right, [:a]).restrict(predicate)
      }

      let(:predicate) {
        Predicate.eq(b: 2)
      }

      it 'pushes the restriction down the tree' do
        expect(subject).to be_a(Operator::NotMatching)
        expect(left_operand).to be_a(Operator::Restrict)
        expect(left_operand.send(:predicate)).to eql(predicate)
        expect(right_operand).to be_a(Relation::InMemory)
      end
    end

  end
end

require 'spec_helper'
module Bmg
  describe "rename optimization" do

    context "rename.restrict" do
      let(:p) {
        Predicate.gt(:a, 10) & Predicate.eq(:b, 2)
      }

      subject {
        Relation.new([
          { x: 1,  b: 2 },
          { x: 11, b: 2 }
        ]).rename(x: :a).restrict(p)
      }

      it 'works' do
        expect(subject).to be_a(Operator::Rename)
        expect(operand).to be_a(Operator::Restrict)
        expect(predicate_of(operand)).to eql(Predicate.gt(:x, 10) & Predicate.eq(:b, 2))
      end
    end

  end
end

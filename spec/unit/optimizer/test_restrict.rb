require 'spec_helper'
module Bmg
  describe "restrict optimization" do

    context "restrict.restrict" do
      let(:p1) {
        Predicate.gt(:a, 10)
      }

      let(:p2) {
        Predicate.gt(:b, 10)
      }

      subject {
        Relation.new([
          { a: 1,  b: 2 },
          { a: 11, b: 2 }
        ]).restrict(p1).restrict(p2)
      }

      it 'works' do
        expect(subject).to be_a(Operator::Restrict)
        expect(operand).to be_a(Leaf)
        expect(subject.send(:predicate)).to eql(p1 & p2)
        expect(operand.send(:operand)).to be_a(Array)
      end
    end

  end
end

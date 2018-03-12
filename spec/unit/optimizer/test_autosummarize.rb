require 'spec_helper'
module Bmg
  describe "autosummarize optimization" do

    context "autosummarize.restrict" do
      subject {
        Relation.new([
          { a: 1, b: 2, c: 7 },
          { a: 1, b: 3, c: 8 }
        ]).autosummarize([:x], b: :group).restrict(predicate)
      }

      context 'when the predicate does not apply to the grouping key' do
        let(:predicate){ Predicate.eq(a: 1) & Predicate.in(:c, [7,8,9]) }

        it 'works' do
          expect(subject).to be_a(Operator::Autosummarize)
          expect(operand).to be_a(Operator::Restrict)
          expect(predicate_of(operand)).to eql(predicate)
        end
      end

      context 'when the predicate does apply to both of them' do
        let(:predicate){ Predicate.eq(a: 1) & Predicate.intersect(:b, [1,2]) }

        it 'works' do
          expect(subject).to be_a(Operator::Restrict)
          expect(predicate_of(subject)).to eql(Predicate.intersect(:b, [1,2]))
          expect(operand).to be_a(Operator::Autosummarize)
          expect(operand(operand)).to be_a(Operator::Restrict)
          expect(predicate_of(operand(operand))).to eql(Predicate.eq(a: 1))
        end
      end
    end

  end
end

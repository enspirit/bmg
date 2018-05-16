require 'spec_helper'
module Bmg
  describe "group optimization" do

    context "group.restrict" do
      let(:relation) {
        Relation.new([
          { a: 1,  b: 2 },
          { a: 11, b: 2 }
        ])
      }

      subject{
        relation.group([:b], :newone).restrict(predicate)
      }

      context 'when the predicate only touches attributes that stay' do
        let(:predicate){ Predicate.eq(a: 1) }

        it 'optimizes by pushing the restriction down' do
          expect(subject).to be_a(Operator::Group)
          expect(subject.send(:attrs)).to eql([:b])
          expect(subject.send(:as)).to eql(:newone)
          expect(operand).to be_a(Operator::Restrict)
          expect(predicate_of(operand)).to eql(predicate)
        end
      end

      context 'when the predicate touches both' do
        let(:onnewone){ Predicate.eq(:newone, :hello) }
        let(:predicate){ Predicate.eq(a: 1) & onnewone }

        it 'splits the predicates and keeps two Restrict' do
          expect(subject).to be_a(Operator::Restrict)
          expect(predicate_of(subject)).to eql(onnewone)
          expect(operand).to be_a(Operator::Group)
          expect(operand(operand)).to be_a(Operator::Restrict)
          expect(predicate_of(operand(operand))).to eql(Predicate.eq(a: 1))
        end
      end
    end
  end
end

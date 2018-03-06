require 'spec_helper'
module Bmg
  describe "allbut optimization" do

    context "allbut.restrict" do
      let(:relation) {
        Relation.new([
          { a: 1,  b: 2 },
          { a: 11, b: 2 }
        ])
      }

      let(:predicate) {
        Predicate.gt(:a, 10)
      }

      let(:allbuted){ [:b] }

      subject{
        relation.allbut(allbuted).restrict(predicate)
      }

      let(:operand) {
        subject.send(:operand)
      }

      it 'optimizes by pushing the restriction down' do
        expect(subject).to be_a(Operator::Allbut)
        expect(subject.send(:butlist)).to be(allbuted)
        expect(operand).to be_a(Operator::Restrict)
        expect(operand.send(:predicate)).to be(predicate)
      end

    end

  end
end

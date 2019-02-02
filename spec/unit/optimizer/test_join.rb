require 'spec_helper'
module Bmg
  describe "join optimization" do

    let(:options) {
      { :split => '-' }
    }

    context "join.autowrap" do
      let(:left) {
        Relation.new([
          { a: 1, b: 2 },
          { a: 3, b: 4 }
        ])
      }
      let(:right) {
        Relation.new([
          { a: 1, c: 4 },
          { a: 1, c: 5 }
        ])
      }

      context 'when both operands are autowrapped with same options' do
        subject{
          left
            .autowrap(options)
            .join(right.autowrap(options), [:a])
            .autowrap(options)
        }

        it 'removes inner autowraps' do
          expect(subject).to be_a(Operator::Autowrap)
          expect(subject.send(:options)[:split]).to eql("-")
          expect(operand(subject)).to be_a(Operator::Join)
          expect(left_operand(operand(subject))).to be(left)
          expect(right_operand(operand(subject))).to be(right)
        end
      end
    end
  end
end

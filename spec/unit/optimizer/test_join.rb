require 'spec_helper'
module Bmg
  describe "join optimization" do

    let(:options) {
      { :split => '-' }
    }

    # context "join.autowrap" do
    #   let(:left) {
    #     Relation.new([
    #       { a: 1, b: 2 },
    #       { a: 3, b: 4 }
    #     ], Type.new.with_attrlist([:a, :b]))
    #   }
    #   let(:right) {
    #     Relation.new([
    #       { a: 1, c: 4 },
    #       { a: 1, c: 5 }
    #     ], Type.new.with_attrlist([:a, :"c-id"]))
    #   }

    #   context 'when both operands are autowrapped with same options' do
    #     subject{
    #       left
    #         .autowrap(options)
    #         .join(right.autowrap(options), [:a])
    #         .autowrap(options)
    #     }

    #     it 'removes inner autowraps' do
    #       expect(subject).to be_a(Operator::Autowrap)
    #       expect(subject.send(:options)[:split]).to eql("-")
    #       expect(operand(subject)).to be_a(Operator::Join)
    #       expect(left_operand(operand(subject))).to be(left)
    #       expect(right_operand(operand(subject))).to be(right)
    #     end
    #   end
    # end

    context "join.restrict" do
      let(:left) {
        Relation.new([
          { a: 1, b: 2 },
          { a: 3, b: 4 }
        ], Type.new.with_attrlist([:a, :b]))
      }
      let(:right) {
        Relation.new([
          { a: 1, c: 4 },
          { a: 1, c: 5 }
        ], Type.new.with_attrlist([:a, :c]))
      }
      subject{
        left
          .join(right, [:a])
          .restrict(predicate)
      }

      context 'when the predicate is native' do
        let(:predicate) {
          Predicate.native(->(t) { t[:a] == 1 })
        }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Restrict)
          expect(subject.send(:predicate)).to be(predicate)
          expect(operand(subject)).to be_a(Operator::Join)
          expect(left_operand(operand(subject))).to be(left)
          expect(right_operand(operand(subject))).to be(right)
        end
      end

      context 'when the predicate compares attributes from both sides' do
        let(:predicate) {
          Predicate.eq(:b, :c)
        }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Restrict)
          expect(subject.send(:predicate)).to be(predicate)
          expect(operand(subject)).to be_a(Operator::Join)
          expect(left_operand(operand(subject))).to be(left)
          expect(right_operand(operand(subject))).to be(right)
        end
      end

      context 'when the predicate can be fully pushed to left' do
        let(:predicate) {
          Predicate.gt(:b, 1)
        }

        it 'pushes it down the tree' do
          expect(subject).to be_a(Operator::Join)
          expect(left_operand(subject)).to be_a(Operator::Restrict)
          expect(left_operand(subject).send(:predicate)).to eql(Predicate.gt(:b, 1))
          expect(right_operand(subject)).to be(right)
        end
      end

      context 'when the predicate can be fully pushed to right' do
        let(:predicate) {
          Predicate.gt(:c, 1)
        }

        it 'pushes it down the tree' do
          expect(subject).to be_a(Operator::Join)
          expect(right_operand(subject)).to be_a(Operator::Restrict)
          expect(right_operand(subject).send(:predicate)).to eql(Predicate.gt(:c, 1))
          expect(left_operand(subject)).to be(left)
        end
      end

      context 'when the predicate can be split with no remains' do
        let(:predicate) {
          Predicate.eq(:b, 1) & Predicate.eq(:c, 1)
        }

        it 'breaks it and pushe subpredicates down the tree' do
          expect(subject).to be_a(Operator::Join)
          expect(left_operand(subject)).to be_a(Operator::Restrict)
          expect(left_operand(subject).send(:predicate)).to eql(Predicate.eq(:b, 1))
          expect(right_operand(subject)).to be_a(Operator::Restrict)
          expect(right_operand(subject).send(:predicate)).to eql(Predicate.eq(:c, 1))
        end
      end

      context 'when the predicate can be fully pushed to both' do
        let(:predicate) {
          Predicate.gt(:a, 1)
        }

        it 'pushes it down the tree' do
          expect(subject).to be_a(Operator::Join)
          expect(left_operand(subject)).to be_a(Operator::Restrict)
          expect(left_operand(subject).send(:predicate)).to eql(Predicate.gt(:a, 1))
          expect(right_operand(subject)).to be_a(Operator::Restrict)
          expect(right_operand(subject).send(:predicate)).to eql(Predicate.gt(:a, 1))
        end
      end

      context 'when the predicate can be split in two parts' do
        let(:predicate) {
          Predicate.gt(:b, 1) & Predicate.eq(:b, :c)
        }

        it 'pushes subpredicates down the tree' do
          expect(subject).to be_a(Operator::Restrict)
          expect(subject.send(:predicate)).to eql(Predicate.eq(:b, :c))
          expect(operand(subject)).to be_a(Operator::Join)
          expect(left_operand(operand(subject))).to be_a(Operator::Restrict)
          expect(left_operand(operand(subject)).send(:predicate)).to eql(Predicate.gt(:b, 1))
          expect(right_operand(operand(subject))).to be(right)
        end
      end

      context 'when the predicate can be split in three parts' do
        let(:predicate) {
          Predicate.eq(:a, 1) & Predicate.gt(:b, 1) & Predicate.lt(:c, 4) & Predicate.eq(:b, :c)
        }

        it 'pushes subpredicates down the tree' do
          expect(subject).to be_a(Operator::Restrict)
          expect(subject.send(:predicate)).to eql(Predicate.eq(:b, :c))
          expect(operand(subject)).to be_a(Operator::Join)
          expect(left_operand(operand(subject))).to be_a(Operator::Restrict)
          expect(left_operand(operand(subject)).send(:predicate)).to eql(Predicate.eq(:a, 1) & Predicate.gt(:b, 1))
          expect(right_operand(operand(subject))).to be_a(Operator::Restrict)
          expect(right_operand(operand(subject)).send(:predicate)).to eql(Predicate.eq(:a, 1) & Predicate.lt(:c, 4))
        end
      end
    end
  end
end

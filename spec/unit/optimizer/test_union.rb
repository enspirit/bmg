require 'spec_helper'
module Bmg
  describe "union_nary optimization" do

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

    let(:third) {
      Relation.new([
        { a: 3 },
      ])
    }

    let(:fourth) {
      Relation.new([
        { a: 4 },
      ])
    }

    def union_nary(operands, options = {})
      Operator::Union.new(Type::ANY, operands, options)
    end

    context "union_nary.restrict" do
      let(:predicate) {
        Predicate.gt(:a, 10)
      }

      context 'when it does not lead to empty relations' do
        subject{
          union_nary([left, right, third]).restrict(predicate)
        }

        it 'works' do
          expect(subject).to be_a(Operator::Union)
          expect(operands.all?{|op|
            op.is_a?(Operator::Restrict) && predicate_of(op) == predicate
          }).to be(true)
        end
      end

      context 'when it leads to empty relations' do

        it 'strips them' do
          subject = union_nary([left, Relation.empty, third]).restrict(predicate)
          expect(subject).to be_a(Operator::Union)
          expect(operands(subject).size).to eql(2)
        end

        it 'returns the single one if a singleton' do
          subject = union_nary([left, Relation.empty]).restrict(predicate)
          expect(subject).to be_a(Operator::Restrict)
          expect(predicate_of(subject)).to eql(predicate)
          expect(operand(subject)).to be(left)
        end

        it 'returns empty when none is kept' do
          subject = union_nary([Relation.empty, Relation.empty]).restrict(predicate)
          expect(subject).to be_a(Relation::Empty)
        end

      end

    end

    let(:base_union) {
      union_nary([left, right])
    }

    context "union_nary.union when the options are compatible" do

      context "when third is empty" do

        subject{
          base_union.union(Relation.empty)
        }

        it 'returns self' do
          expect(subject).to be(base_union)
        end

      end

      context "when third is not a union or a union_nary" do

        subject{
          base_union.union(third)
        }

        it 'works' do
          expect(subject).to be_a(Operator::Union)
          expect(operands).to eql([left, right, third])
        end

      end

      context "when third a union" do

        subject{
          base_union.union(third.union(fourth))
        }

        it 'works' do
          expect(subject).to be_a(Operator::Union)
          expect(operands).to eql([left, right, third, fourth])
        end

      end
    end

    context "when the options are not compatible" do

      context "when third is not a union" do

        subject{
          base_union.union(third, all: true)
        }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Union)
          expect(operands.size).to eql(2)
          expect(operands.first).to be_a(Operator::Union)
          expect(operands.last).to be_a(Relation::InMemory)
        end

      end

      context "when third is a union" do

        subject{
          base_union.union(third.union(fourth, all: true))
        }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Union)
          expect(operands.size).to eql(2)
          expect(operands.first).to be_a(Operator::Union)
          expect(operands.last).to be_a(Operator::Union)
        end

      end

    end

  end
end

require 'spec_helper'
module Bmg
  describe "constants optimization" do

    let(:relation) {
      Relation.new([
        { a: 1,  b: 2 },
        { a: 11, b: 2 }
      ])
    }

    let(:constants) {
      { c: 3 }
    }

    context "constants.page" do

      subject{
        relation.constants(constants).page(ordering, 7, page_size: 19)
      }

      context "when the ordering does not touch constants" do
        let(:ordering){ [:a] }

        it 'pushes page down the tree' do
          expect(subject).to be_a(Operator::Constants)
          expect(subject.send(:the_constants)).to eql(constants)
          expect(operand).to be_a(Operator::Page)
          expect(operand.send(:ordering)).to eql([:a])
          expect(operand.send(:page_index)).to eql(7)
          expect(operand.send(:options)[:page_size]).to eql(19)
        end
      end

      context "when the ordering touches constants" do
        let(:ordering){ [:a, [:c, :desc]] }

        it 'does not push page' do
          expect(subject).to be_a(Operator::Page)
          expect(operand).to be_a(Operator::Constants)
        end
      end
    end

    context "constants.restrict" do

      subject{
        relation.constants(constants).restrict(predicate)
      }

      context 'when the predicate does not touches the constants' do

        let(:predicate){ Predicate.eq(a: 1) }

        it 'optimizes by pushing the restriction down' do
          expect(subject).to be_a(Operator::Constants)
          expect(subject.send(:the_constants)).to be(constants)
          expect(operand).to be_a(Operator::Restrict)
          expect(predicate_of(operand)).to eql(predicate)
        end

      end

      context 'when the predicate touches the constants' do

        context 'when leading to a tautology' do

          let(:predicate){ Predicate.eq(c: 3) }

          it 'strips the restriction completely' do
            expect(subject).to be_a(Operator::Constants)
            expect(subject.send(:the_constants)).to be(constants)
          end

        end

        context 'when leading to a contradiction' do

          let(:predicate){ Predicate.eq(c: 7) }

          it 'returns an empty result' do
            expect(subject).to be_a(Relation::Empty)
          end

        end

      end

      context 'when the predicate can be split' do

        context 'when the constant part leads to a tautology' do

          let(:predicate){ Predicate.eq(a: 1, c: 3) }

          it 'strips the constant restriction and pushes back the rest' do
            expect(subject).to be_a(Operator::Constants)
            expect(subject.send(:the_constants)).to be(constants)
            expect(subject.send(:operand)).to be_a(Operator::Restrict)
            expect(subject.send(:operand).send(:predicate)).to eql(Predicate.eq(a: 1))
          end

        end

        context 'when the constant part leads to a contradition' do

          let(:predicate){ Predicate.eq(a: 1, c: 4) }

          it 'returns an empty result' do
            expect(subject).to be_a(Relation::Empty)
          end

        end

      end

      context 'when the predicate cannot be split' do

        context 'when nothing can be pushed down' do
          let(:predicate){ Predicate.eq(a: 1) | Predicate.eq(c: 3) }

          it 'does not optimize' do
            expect(subject).to be_a(Operator::Restrict)
            expect(predicate_of(subject)).to be(predicate)
            expect(operand).to be_a(Operator::Constants)
            expect(operand.send(:the_constants)).to be(constants)
          end
        end

        context 'when something can be pushed down' do
          let(:predicate){ Predicate.eq(a: 1) & (Predicate.eq(c: 3) | Predicate.eq(d: 4)) }

          it 'pushes down what can be pushed and keeps the rest' do
            expect(subject).to be_a(Operator::Restrict)
            expect(predicate_of(subject)).to eql(Predicate.eq(c: 3) | Predicate.eq(d: 4))
            expect(operand).to be_a(Operator::Constants)
            expect(operand.send(:the_constants)).to be(constants)
            expect(operand(operand)).to be_a(Operator::Restrict)
            expect(predicate_of(operand(operand))).to eql(Predicate.eq(a: 1))
          end
        end

      end

      context 'when the predicate is native' do

        let(:predicate){ Predicate.native(->(t){ true }) }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Restrict)
          expect(predicate_of(subject)).to be(predicate)
          expect(operand).to be_a(Operator::Constants)
          expect(operand.send(:the_constants)).to be(constants)
        end

      end

    end

  end
end

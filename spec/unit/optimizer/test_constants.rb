require 'spec_helper'
module Bmg
  describe "constants optimization" do

    context "constants.restrict" do
      let(:relation) {
        Relation.new([
          { a: 1,  b: 2 },
          { a: 11, b: 2 }
        ])
      }

      let(:constants) {
        { c: 3 }
      }

      subject{
        relation.constants(constants).restrict(predicate)
      }

      let(:operand) {
        subject.send(:operand)
      }

      context 'when the predicate does not touches the constants' do

        let(:predicate){ Predicate.eq(a: 1) }

        it 'optimizes by pushing the restriction down' do
          expect(subject).to be_a(Operator::Constants)
          expect(subject.send(:constants)).to be(constants)
          expect(operand).to be_a(Operator::Restrict)
          expect(operand.send(:predicate)).to eql(predicate)
        end

      end

      context 'when the predicate touches the constants' do

        let(:predicate){ Predicate.eq(c: 3) }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Restrict)
          expect(subject.send(:predicate)).to eql(predicate)
          expect(operand).to be_a(Operator::Constants)
          expect(operand.send(:constants)).to be(constants)
        end

      end

      context 'when the predicate can be split' do

        let(:predicate){ Predicate.eq(a: 1, c: 3) }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Restrict)
          expect(subject.send(:predicate)).to eql(Predicate.eq(c: 3))
          expect(operand).to be_a(Operator::Constants)
          expect(operand.send(:constants)).to be(constants)
          expect(operand.send(:operand)).to be_a(Operator::Restrict)
          expect(operand.send(:operand).send(:predicate)).to eql(Predicate.eq(a: 1))
        end

      end

      context 'when the predicate cannot be split' do

        let(:predicate){ Predicate.eq(a: 1) | Predicate.eq(c: 3) }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Restrict)
          expect(subject.send(:predicate)).to be(predicate)
          expect(operand).to be_a(Operator::Constants)
          expect(operand.send(:constants)).to be(constants)
        end

      end

      context 'when the predicate is native' do

        let(:predicate){ Predicate.native(->(t){ true }) }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Restrict)
          expect(subject.send(:predicate)).to be(predicate)
          expect(operand).to be_a(Operator::Constants)
          expect(operand.send(:constants)).to be(constants)
        end

      end

    end

  end
end

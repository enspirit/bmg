require 'spec_helper'
module Bmg
  describe "extend optimization" do

    context "extend.restrict" do
      let(:relation) {
        Relation.new([
          { a: 1,  b: 2 },
          { a: 11, b: 2 }
        ])
      }

      let(:extension) {
        { c: ->(t){ 12 } }
      }

      subject{
        relation.extend(extension).restrict(predicate)
      }

      context 'when the predicate does not touches the extension' do
        let(:predicate){ Predicate.eq(a: 1) }

        it 'optimizes by pushing the restriction down' do
          expect(subject).to be_a(Operator::Extend)
          expect(subject.send(:extension)).to be(extension)
          expect(operand).to be_a(Operator::Restrict)
          expect(predicate_of(operand)).to eql(predicate)
        end
      end

      context 'when the predicate touches both' do
        let(:predicate){ Predicate.eq(a: 1, c: 15) }

        it 'splits the predicates and keeps two Restrict' do
          expect(subject).to be_a(Operator::Restrict)
          expect(predicate_of(subject)).to eql(Predicate.eq(c: 15))
          expect(operand).to be_a(Operator::Extend)
          expect(operand.send(:extension)).to be(extension)
          expect(operand(operand)).to be_a(Operator::Restrict)
          expect(predicate_of(operand(operand))).to eql(Predicate.eq(a: 1))
        end
      end
    end

    context "extend.page" do
      let(:relation) {
        Relation.new([
          { a: 1,  b: 2 },
          { a: 11, b: 2 }
        ])
      }

      subject {
        relation.extend(extension).page([:a], 1, page_size: 2)
      }

      context 'when the ordering does not touch the extension' do
        let(:extension) {
          { c: ->(t){ 12 } }
        }

        it 'pushes the page down' do
          expect(subject).to be_a(Operator::Extend)
          expect(subject.send(:extension)).to be(extension)
          expect(operand(subject)).to be_a(Operator::Page)
          expect(operand(subject).send(:ordering)).to eql([:a])
          expect(operand(subject).send(:options)[:page_size]).to eql(2)
        end
      end

      context 'when the ordering touches the extension' do
        let(:extension) {
          { a: ->(t){ t[:a] * 2 } }
        }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Page)
        end
      end
    end

  end
end

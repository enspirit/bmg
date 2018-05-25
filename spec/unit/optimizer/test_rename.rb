require 'spec_helper'
module Bmg
  describe "rename optimization" do

    context "rename.page" do

      subject {
        Relation.new([
          { x: 1,  b: 2 },
          { x: 11, b: 2 }
        ]).rename(x: :a).page(ordering, 7, page_size: 19)
      }

      context 'when the ordering does not touch the renaming' do
        let(:ordering){ [:b] }

        it 'pushes the page down the tree' do
          expect(subject).to be_a(Operator::Rename)
          expect(operand).to be_a(Operator::Page)
          expect(operand.send(:ordering)).to eql(ordering)
          expect(operand.send(:page_index)).to eql(7)
          expect(operand.send(:options)[:page_size]).to eql(19)
        end
      end

      context 'when the ordering touches the renaming' do
        let(:ordering){ [[:a, :asc], [:b, :desc]] }

        it 'pushes the page down the tree but renames it' do
          expect(subject).to be_a(Operator::Rename)
          expect(operand).to be_a(Operator::Page)
          expect(operand.send(:ordering)).to eql([[:x, :asc], [:b, :desc]])
          expect(operand.send(:page_index)).to eql(7)
          expect(operand.send(:options)[:page_size]).to eql(19)
        end
      end
    end

    context "rename.restrict" do
      let(:p) {
        Predicate.gt(:a, 10) & Predicate.eq(:b, 2)
      }

      subject {
        Relation.new([
          { x: 1,  b: 2 },
          { x: 11, b: 2 }
        ]).rename(x: :a).restrict(p)
      }

      it 'works' do
        expect(subject).to be_a(Operator::Rename)
        expect(operand).to be_a(Operator::Restrict)
        expect(predicate_of(operand)).to eql(Predicate.gt(:x, 10) & Predicate.eq(:b, 2))
      end
    end

  end
end

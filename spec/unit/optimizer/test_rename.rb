require 'spec_helper'
module Bmg
  describe "rename optimization" do

    let(:relation) {
      Relation.new([
        { x: 1,  b: 2 },
        { x: 11, b: 2 }
      ])
    }

    context 'when renaming can be simplified or removed' do
      subject{
        relation.rename(renaming)
      }

      context 'with empty renaming' do
        let(:renaming){ {} }

        it 'removes it' do
          expect(subject).to be(relation)
        end
      end

      context 'with equality renaming' do
        let(:renaming){ { :x => :x } }

        it 'removes it' do
          expect(subject).to be(relation)
        end
      end

      context 'with simplifiable renaming' do
        let(:renaming){ { :x => :x, :b => :z } }

        it 'removes it' do
          expect(subject).to be_a(Operator::Rename)
          expect(subject.send(:renaming)).to eql({:b => :z})
        end
      end
    end

    context "rename.page" do

      subject {
        relation.rename(x: :a).page(ordering, 7, page_size: 19)
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
        relation.rename(x: :a).restrict(p)
      }

      it 'works' do
        expect(subject).to be_a(Operator::Rename)
        expect(operand).to be_a(Operator::Restrict)
        expect(predicate_of(operand)).to eql(Predicate.gt(:x, 10) & Predicate.eq(:b, 2))
      end
    end

  end
end

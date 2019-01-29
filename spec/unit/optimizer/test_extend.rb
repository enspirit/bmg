require 'spec_helper'
module Bmg
  describe "extend optimization" do

    let(:relation) {
      Relation.new([
        { a: 1,  b: 2 },
        { a: 11, b: 2 }
      ])
    }

    let(:c_ext) {
      ->(t){ 12 }
    }

    let(:d_ext) {
      ->(t){ 13 }
    }

    context 'extend with empty extension' do
      subject {
        relation.extend({})
      }

      it 'returns the extension itself' do
        expect(subject).to be(relation)
      end
    end

    context "extend.allbut" do
      subject {
        relation.extend(extension).allbut(butlist)
      }

      context 'when the butlist covers the whole extension' do
        let(:extension) {
          { c: c_ext, d: d_ext }
        }
        let(:butlist){
          [:a, :c, :d]
        }

        # rel(:a, :b).extend(:c, :d).allbut(:a, :c, :d) => [:b]
        # becomes
        # rel(:a, :b).allbut(:a)
        it 'strips the extension completely and simplifies the butlist' do
          expect(subject).to be_a(Operator::Allbut)
          expect(subject.send(:butlist)).to eql([:a])
          expect(operand(subject)).to be(relation)
        end
      end

      context 'when the butlist touches the extension, but not whole' do
        let(:extension) {
          { c: c_ext, d: d_ext }
        }
        let(:butlist){
          [:a, :c]
        }

        # rel(:a, :b).extend(:c, :d).allbut(:a, :c) => [:b, :d]
        # becomes
        # rel(:a, :b).extend(:d).allbut(:a) => [:b, :d]
        it 'simplifies the extension' do
          expect(subject).to be_a(Operator::Allbut)
          expect(subject.send(:butlist)).to eql([:a])
          expect(operand(subject)).to be_a(Operator::Extend)
          expect(operand(subject).send(:extension)).to eql(d: d_ext)
        end
      end

      context 'when the butlist does not touch the extension' do
        let(:extension) {
          { c: c_ext, d: d_ext }
        }
        let(:butlist){
          [:a, :b]
        }

        # rel(:a, :b).extend(:c, :d).allbut(:a, :b) => [:c, :d]
        # becomes
        # rel(:a, :b).extend(:c, :d).allbut(:a, :c) => [:c, :d]
        it 'does not optimize at all' do
          expect(subject).to be_a(Operator::Allbut)
          expect(subject.send(:butlist)).to eql(butlist)
          expect(operand(subject)).to be_a(Operator::Extend)
          expect(operand(subject).send(:extension)).to eql(extension)
        end
      end
    end

    context "extend.restrict" do

      let(:extension) {
        { c: c_ext }
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

      subject {
        relation.extend(extension).page([:a], 1, page_size: 2)
      }

      context 'when the ordering does not touch the extension' do
        let(:extension) {
          { c: c_ext }
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

    context "extend.project" do

      subject {
        relation.extend(extension).project(projection)
      }

      # rel(:a, :b).extend(:c).project(:a) => [:a]
      # becomes
      # rel(:a, :b).project(:a) => [:a]
      context 'when the projection does not touch the extension at all' do
        let(:extension) {
          { c: c_ext }
        }
        let(:projection){
          [:a]
        }

        it 'strips the extension completely' do
          expect(subject).to be_a(Operator::Project)
          expect(subject.send(:attrlist)).to eql(projection)
          expect(operand(subject)).to be(relation)
        end
      end

      # rel(:a, :b).extend(:c, :d).project(:a, :c, :d) => [:a, :c, :d]
      # becomes
      # rel(:a, :b).extend(:c, :d).project(:a, :c, :d) => [:a, :c, :d]
      context 'when the projection covers the whole extension' do
        let(:extension) {
          { c: c_ext, d: d_ext }
        }
        let(:projection){
          [:a, :c, :d]
        }

        it 'does not optimize at all' do
          expect(subject).to be_a(Operator::Project)
          expect(subject.send(:attrlist)).to eql(projection)
          expect(operand(subject)).to be_a(Operator::Extend)
          expect(operand(subject).send(:extension)).to eql(extension)
        end
      end

      # rel(:a, :b).extend(:c, :d).project(:a, :c) => [:a, :c]
      # becomes
      # rel(:a, :b).extend(:c).project(:a, :c) => [:a, :c]
      context 'when the projection covers part of the extension' do
        let(:extension) {
          { c: c_ext, d: d_ext }
        }
        let(:projection){
          [:a, :c]
        }

        it 'simplifies them' do
          expect(subject).to be_a(Operator::Project)
          expect(subject.send(:attrlist)).to eql(projection)
          expect(operand(subject)).to be_a(Operator::Extend)
          expect(operand(subject).send(:extension)).to eql(c: c_ext)
        end
      end
    end

  end
end

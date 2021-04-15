require 'spec_helper'
module Bmg
  describe "transform optimization" do

    let(:relation) {
      Relation.new([
        { a: 1,  b: 2 },
        { a: 11, b: 2 }
      ])
    }

    before do
      class Operator::Transform
        public :transformation
      end
      class Operator::Project
        public :attrlist
      end
    end

    context 'extend with empty transformation' do
      subject {
        relation.transform({})
      }

      it 'returns the relation itself' do
        expect(subject).to be(relation)
      end
    end

    context "transform.allbut" do
      subject {
        relation.transform(transformation).allbut(butlist)
      }

      context 'when the transformation & butlist do not intersect' do
        let(:transformation){{
          :a => :to_s
        }}
        let(:butlist) {
          [:b]
        }

        it 'pushes the allbut down the tree' do
          expect(subject).to be_a(Operator::Transform)
          expect(operand).to be_a(Operator::Allbut)
          expect(operand.butlist).to eql(butlist)
          expect(operand(operand)).to be(relation)
        end
      end

      context 'when some transformations are thrown away' do
        let(:transformation){{
          :a => :to_s,
          :b => :to_s
        }}
        let(:butlist) {
          [:a]
        }

        it 'the allbut is pushed down, and transformation simplified' do
          expect(subject).to be_a(Operator::Transform)
          expect(subject.transformation).to eql({:b => :to_s})
          expect(operand).to be_a(Operator::Allbut)
          expect(operand.butlist).to eql(butlist)
          expect(operand(operand)).to be(relation)
        end
      end

      context 'when all transformations are thrown away' do
        let(:transformation){{
          :a => :to_s
        }}
        let(:butlist) {
          [:a]
        }

        it 'the allbut is pushed down, and transformation removed' do
          expect(subject).to be_a(Operator::Allbut)
          expect(subject.butlist).to eql(butlist)
          expect(operand).to be(relation)
        end
      end

      context 'when transformation is not a Hash' do
        let(:transformation){
          :to_s
        }
        let(:butlist) {
          [:a]
        }

        it 'the allbut is pushed down, and transformation kept unchanged' do
          expect(subject).to be_a(Operator::Transform)
          expect(subject.transformation).to eql(:to_s)
          expect(operand).to be_a(Operator::Allbut)
          expect(operand.butlist).to eql(butlist)
          expect(operand(operand)).to be(relation)
        end
      end
    end

    context "transform.project" do
      subject {
        relation.transform(transformation).project(attrlist)
      }

      context 'when the transformation & attrlist do not intersect' do
        let(:transformation){{
          :a => :to_s
        }}
        let(:attrlist) {
          [:b]
        }

        it 'the transformation is removed' do
          expect(subject).to be_a(Operator::Project)
          expect(subject.attrlist).to eql(attrlist)
          expect(operand).to be(relation)
        end
      end

      context 'when the transformation & attrlist do intersect' do
        let(:transformation){{
          :a => :to_s,
          :b => :to_s
        }}
        let(:attrlist) {
          [:b]
        }

        it 'the projection is pushed, and transformation simplified' do
          expect(subject).to be_a(Operator::Transform)
          expect(subject.transformation).to eql(:b => :to_s)
          expect(operand).to be_a(Operator::Project)
          expect(operand.attrlist).to eql(attrlist)
          expect(operand(operand)).to be(relation)
        end
      end

      context 'when transformation attributes are unknown' do
        let(:transformation){
          :to_s
        }
        let(:attrlist) {
          [:b]
        }

        it 'the projection is pushed, and transformation kept unchanged' do
          expect(subject).to be_a(Operator::Transform)
          expect(subject.transformation).to eql(:to_s)
          expect(operand).to be_a(Operator::Project)
          expect(operand.attrlist).to eql(attrlist)
          expect(operand(operand)).to be(relation)
        end
      end
    end
  end
end
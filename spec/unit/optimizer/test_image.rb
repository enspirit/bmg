require 'spec_helper'
module Bmg
  describe "image optimization" do

    let(:left_data) {
      [
        { a: 1, b: 2 },
        { a: 3, b: 4 }
      ]
    }

    let(:left) {
      Relation.new(left_data)
    }

    let(:right_data) {
      [
        { a: 1, c: 4 },
        { a: 1, c: 5 }
      ]
    }

    let(:right) {
      Relation.new(right_data)
    }

    context 'image.allbut' do

      context 'when the butlist includes the new attribute' do

        subject{
          left.image(right, :image, [:a]).allbut([:image, :b])
        }

        it 'strips the image completely' do
          expect(subject).to be_a(Operator::Allbut)
          expect(subject.butlist).to eql([:b])
          expect(operand).to be(left)
        end

      end

      context 'when the butlist includes the new attribute only' do

        subject{
          left.image(right, :image, [:a]).allbut([:image])
        }

        it 'strips the image & the allbut completely' do
          expect(subject).to be(left)
        end

      end

      context 'when the butlist does not have the new attribute at all' do

        subject{
          left.image(right, :image, [:a]).allbut([:b])
        }

        it 'pushes the allbut down the tree' do
          expect(subject).to be_a(Operator::Image)
          expect(left_operand).to be_a(Operator::Allbut)
          expect(left_operand.butlist).to eql([:b])
        end

      end

      context 'when the butlist intersects with on attrlist' do

        subject{
          left.image(right, :image, [:a]).allbut([:a])
        }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Allbut)
          expect(subject.butlist).to eql([:a])
          expect(operand).to be_a(Operator::Image)
          expect(left_operand(operand)).to be(left)
          expect(right_operand(operand)).to be(right)
        end

      end

    end

    context "image.matching" do
      subject{
        left.image(right, :image, [:a]).matching(third, on)
      }

      let(:third) {
        Relation.new [
          { a: 1, d: 4 },
          { a: 1, d: 5 }
        ]
      }

      context 'when the matching does not use the newly attribute' do
        let(:on) {
          [:a]
        }

        it 'pushes the matching down the tree' do
          expect(subject).to be_a(Operator::Image)
          expect(subject.on).to eql([:a])
          expect(subject.as).to eql(:image)
          expect(left_operand).to be_a(Operator::Matching)
          expect(left_operand.on).to eql(on)
          expect(left_operand(left_operand)).to be(left)
          expect(right_operand(left_operand)).to be(third)
          expect(right_operand).to be(right)
        end
      end

      context 'when the matching does use the newly attribute' do
        let(:on) {
          [:image, :a]
        }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Matching)
          expect(subject.on).to eql(on)
          expect(left_operand).to be_a(Operator::Image)
        end
      end
    end

    context "image.page" do

      context 'when the ordering does not touch the new attribute' do

        subject{
          left.image(right, :image, [:a]).page([:a], 7, page_size: 17)
        }

        it 'pushes the page down the tree' do
          expect(subject).to be_a(Operator::Image)
          expect(subject.send(:options)[:array]).to eql(false)
          expect(left_operand).to be_a(Operator::Page)
          expect(left_operand.send(:ordering)).to eql([:a])
          expect(left_operand.send(:page_index)).to eql(7)
          expect(left_operand.send(:options)[:page_size]).to eql(17)
        end

      end

      context 'when the ordering touches the new attribute' do

        subject{
          left.image(right, :image, [:a]).page([:a, [:image, :desc]], 7, page_size: 17)
        }

        it 'pushes the page down the tree' do
          expect(subject).to be_a(Operator::Page)
          expect(operand).to be_a(Operator::Image)
        end

      end

    end

    context "image.project" do
      context 'when the image attributes is projected away' do
        subject{
          left.image(right, :image, [:a]).project([:a])
        }

        it 'removes the image completely' do
          expect(subject).to be_a(Operator::Project)
          expect(subject.send(:attrlist)).to eql([:a])
          expect(operand).to be(left)
        end
      end

      context 'when the image attributes is kept' do
        subject{
          left.image(right, :image, [:a]).project([:image])
        }

        it 'keeps the image operator' do
          expect(subject).to be_a(Operator::Project)
          expect(subject.send(:attrlist)).to eql([:image])
          expect(operand).to be_a(Operator::Image)
          expect(operand.send(:as)).to eql(:image)
          expect(operand.send(:on)).to eql([:a])
          expect(left_operand(operand)).to be(left)
          expect(right_operand(operand)).to be(right)
        end
      end
    end

    context "image.restrict" do

      subject{
        left.image(right, :image, [:a]).restrict(predicate)
      }

      context 'when restriction does not touch the new attribute' do
        let(:predicate) {
          Predicate.eq(b: 2)
        }

        it 'optimizes by pushing the restriction down' do
          expect(subject).to be_a(Operator::Image)
          expect(left_operand).to be_a(Operator::Restrict)
          expect(left_operand.send(:predicate)).to eql(predicate)
          expect(right_operand).to be_a(Relation::InMemory)
        end
      end

      context 'when restriction touches the new attribute only' do
        let(:predicate) {
          Predicate.eq(image: 2)
        }

        it 'does not optimize at all' do
          expect(subject).to be_a(Operator::Restrict)
          expect(operand).to be_a(Operator::Image)
        end
      end

      context 'when predicate cannot be split' do
        let(:predicate) {
          Predicate.native(->(t){ false })
        }

        it 'does not optimize at all' do
          expect(subject).to be_a(Operator::Restrict)
          expect(operand).to be_a(Operator::Image)
        end
      end

      context 'when restriction touches all shared attributes' do
        let(:predicate) {
          Predicate.eq(a: 1)
        }

        it 'optimizes both sides' do
          expect(subject).to be_a(Operator::Image)
          expect(left_operand).to be_a(Operator::Restrict)
          expect(left_operand.send(:predicate)).to eql(predicate)
          expect(right_operand).to be_a(Operator::Restrict)
          expect(right_operand.send(:predicate)).to eql(predicate)
        end
      end

      context 'when restriction touches all attributes and can still be optimized' do
        let(:predicate) {
          Predicate.eq(a: 1, b: 2, image: 3)
        }

        it 'optimizes both sides' do
          expect(subject).to be_a(Operator::Restrict)
          expect(subject.send(:predicate)).to eql(Predicate.eq(image: 3))
          expect(operand).to be_a(Operator::Image)
          expect(operand.send(:left)).to be_a(Operator::Restrict)
          expect(operand.send(:left).send(:predicate)).to eql(Predicate.eq(a: 1, b: 2))
          expect(operand.send(:right)).to be_a(Operator::Restrict)
          expect(operand.send(:right).send(:predicate)).to eql(Predicate.eq(a: 1))
        end
      end

      context 'when restriction touches all attributes but cannot be right-optimized' do
        let(:predicate) {
          (Predicate.eq(a: 1) | Predicate.eq(b: 7)) & Predicate.eq(b: 2, image: 3)
        }

        it 'optimizes left, but not right' do
          expect(subject).to be_a(Operator::Restrict)
          expect(subject.send(:predicate)).to eql(Predicate.eq(image: 3))
          expect(operand).to be_a(Operator::Image)
          expect(operand.send(:left)).to be_a(Operator::Restrict)
          expect(operand.send(:left).send(:predicate)).to eql((Predicate.eq(a: 1) | Predicate.eq(b: 7)) & Predicate.eq(b: 2))
          expect(operand.send(:right)).to be(right)
        end
      end

    end

  end
end

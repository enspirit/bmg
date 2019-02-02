require 'spec_helper'
module Bmg
  describe "autowrap optimization" do

    let(:options) {
      { :split => '-' }
    }

    let(:relation) {
      Relation.new([
        { :a => 1,  :"b-id" => 2 },
        { :a => 11, :"b-id" => 2 }
      ], type)
    }

    let(:type) {
      Type.new.with_attrlist([:a, :"b-id"])
    }

    context "autowrap.autowrap" do
      subject {
        relation.autowrap(options).autowrap(options2)
      }

      context 'when different options' do
        let(:options2){
          { :split => '_' }
        }

        it 'keeps both' do
          expect(subject).to be_a(Operator::Autowrap)
          expect(subject.send(:options)[:split]).to eql("_")
          expect(operand(subject)).to be_a(Operator::Autowrap)
          expect(operand(subject).send(:options)[:split]).to eql("-")
        end
      end

      context 'when same options' do
        let(:options2){
          { :split => '-' }
        }

        it 'removes unnecessary one' do
          expect(subject).to be_a(Operator::Autowrap)
          expect(subject.send(:options)[:split]).to eql("-")
          expect(operand(subject)).to be(relation)
        end
      end
    end

    context "autowrap.join when left attributes are known" do
      subject {
        relation.autowrap(options).join(right, on)
      }

      let(:type) {
        Type.new.with_attrlist([:a, :"b-id"])
      }

      context 'when right attributes are not known' do
        let(:right){
          Relation.new([
            { :a => 1, :b => {id: 2}, :c => 3 }
          ])
        }
        let(:on){
          [:a]
        }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Join)
          expect(left_operand(subject)).to be_a(Operator::Autowrap)
          expect(right_operand(subject)).to be(right)
        end
      end

      context 'when right attributes would be wrongly autowrapped' do
        let(:right){
          Relation.new([
            { :a => 1, :"c-id" => 3 }
          ], Type.new.with_attrlist([:a, :"c-id"]))
        }
        let(:on){
          [:a]
        }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Join)
          expect(left_operand(subject)).to be_a(Operator::Autowrap)
          expect(right_operand(subject)).to be(right)
        end
      end

      context 'when join attributes are not autowrapped ones' do
        let(:right){
          Relation.new([
            { :a => 1, :b => {id: 2}, :c => 3 }
          ], Type.new.with_attrlist([:a, :b, :c]))
        }
        let(:on){
          [:a]
        }

        it 'pushes the join down the tree' do
          expect(subject).to be_a(Operator::Autowrap)
          expect(subject.send(:options)[:split]).to eql("-")
          expect(operand(subject)).to be_a(Operator::Join)
          expect(operand(subject).send(:on)).to eql(on)
        end
      end

      context 'when join applies the other way round' do
        subject {
          relation.join(right.autowrap(options), on)
        }
        let(:right){
          Relation.new([
            { :a => 1, :c_id => 3 }
          ], Type.new.with_attrlist([:a, :c_id]))
        }
        let(:options) {
          { :split => '_' }
        }
        let(:on){
          [:a]
        }

        it 'applies the join on the right side' do
          expect(subject).to be_a(Operator::Autowrap)
          expect(subject.send(:options)[:split]).to eql("_")
          expect(operand(subject)).to be_a(Operator::Join)
          expect(operand(subject).send(:on)).to eql(on)
          expect(left_operand(operand(subject))).to be(relation)
          expect(right_operand(operand(subject))).to be(right)
        end
      end

      context 'when join between two identical autowraps' do
        subject {
          relation.autowrap(options).join(right.autowrap(options), on)
        }
        let(:right){
          Relation.new([
            { :a => 1, :"c-id" => 3 }
          ], Type.new.with_attrlist([:a, :"c-id"]))
        }
        let(:on){
          [:a]
        }

        it 'optimizes and keeps only one autowrap' do
          expect(subject).to be_a(Operator::Autowrap)
          expect(subject.send(:options)[:split]).to eql("-")
          expect(operand(subject)).to be_a(Operator::Join)
          expect(operand(subject).send(:on)).to eql(on)
          expect(left_operand(operand(subject))).to be(relation)
          expect(right_operand(operand(subject))).to be(right)
        end
      end
    end

    context "autowrap.page when attributes are known" do
      subject {
        relation.autowrap(options).page(page_ordering, page_index, page_options)
      }

      let(:type) {
        Type.new.with_attrlist([:a, :"b-id"])
      }

      let(:page_ordering) {
        [[:a, :desc]]
      }

      let(:page_index){
        1
      }

      let(:page_options){
        { page_size: 18 }
      }

      context 'when the ordering does not touch new attribute' do

        it 'pushes the page down the tree' do
          expect(subject).to be_a(Operator::Autowrap)
          expect(subject.send(:options)[:split]).to eql("-")
          expect(operand).to be_a(Operator::Page)
          expect(operand.send(:ordering)).to eql(page_ordering)
          expect(operand.send(:page_index)).to eql(page_index)
          expect(operand.send(:options)).to eql(page_options)
        end

      end

    end

    context "autowrap.rename" do
      subject {
        relation.autowrap(options).rename(renaming)
      }

      context 'when renaming is safe' do
        let(:renaming) {
          { :a => :z }
        }

        it 'pushes the renaming down the tree' do
          expect(subject).to be_a(Operator::Autowrap)
          expect(subject.send(:options)[:split]).to eql("-")
          expect(operand(subject)).to be_a(Operator::Rename)
          expect(operand(subject).send(:renaming)).to eql(renaming)
        end
      end

      context 'when renaming touches an autowrapped attr' do
        let(:renaming) {
          { :b => :y }
        }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Rename)
        end
      end

      context 'when renaming would yield a wrong autowrapping' do
        let(:renaming) {
          { :a => :"a-id" }
        }

        it 'does not optimize' do
          expect(subject).to be_a(Operator::Rename)
        end
      end
    end

    context "autowrap.restrict" do

      subject {
        relation.autowrap(options).restrict(predicate)
      }

      context 'when attributes are not known' do
        let(:type) {
          Type::ANY
        }

        let(:predicate) {
          Predicate.eq(:a, 1)
        }

        it 'does not push attributes down' do
          expect(subject).to be_a(Operator::Restrict)
          expect(predicate_of(subject)).to be(predicate)
          expect(operand).to be_a(Operator::Autowrap)
        end
      end

      context 'when attributes are known' do
        let(:type) {
          Type.new.with_attrlist([:a, :"b-id"])
        }

        context 'when the restriction does not touch autowrapped ones' do
          let(:predicate) {
            Predicate.eq(:a, 1)
          }

          it 'pushes the restriction down the tree' do
            expect(subject).to be_a(Operator::Autowrap)
            expect(subject.send(:options)[:split]).to eql('-')
            expect(operand).to be_a(Operator::Restrict)
            expect(predicate_of(operand)).to be(predicate)
          end
        end

        context 'when the restriction touches autowrapped ones only' do
          let(:predicate) {
            Predicate.eq(:b, { id: 2 })
          }

          it 'pushes the restriction down the tree' do
            expect(subject).to be_a(Operator::Restrict)
            expect(predicate_of(subject)).to be(predicate)
            expect(operand).to be_a(Operator::Autowrap)
          end
        end
      end

    end

  end
end

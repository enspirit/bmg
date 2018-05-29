require 'spec_helper'
module Bmg
  describe "autowrap optimization" do

    let(:options) {
      { :split => '-' }
    }

    let(:data) {
      [
        { :a => 1,  :"b-id" => 2 },
        { :a => 11, :"b-id" => 2 }
      ]
    }

    let(:relation) {
      Relation.new(data, type)
    }

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

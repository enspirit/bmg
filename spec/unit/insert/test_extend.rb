require 'spec_helper'
module Bmg
  module Operator
    describe Extend, "Insert logic" do

      let(:extend_op){
        Extend.new(Type::ANY, operand, { :b => ->(t){ 18 } })
      }

      let(:operand){
        Object.new
      }

      subject{ extend_op.insert(inserted) }

      context 'with a tuple not having extension attributes' do
        let(:inserted){
          { a: 17 }
        }

        it 'inserts it on operand' do
          expect(operand).to receive(:insert){|t|
            expect(t).to eql(a: 17)
            :yep
          }
          expect(subject).to eql(:yep)
        end
      end

      context 'with a Relation not having extension attributes' do
        let(:inserted){
          Leaf.new Type::ANY, [{ a: 17 }]
        }

        it 'inserts it on operand' do
          expect(operand).to receive(:insert){|t|
            expect(t).to be_a(Operator::Allbut)
            expect(t.send(:butlist)).to eql([:b])
            :yep
          }
          expect(subject).to eql(:yep)
        end
      end

      context 'with an Enumerable of tuples' do
        let(:inserted){
          [{ a: 17, b: 18 }]
        }

        it 'inserts it on operand' do
          expect(operand).to receive(:insert){|t|
            expect(t).to eql([{ a: 17 }])
            :yep
          }
          expect(subject).to eql(:yep)
        end
      end

      context 'with a tuple exposing extension attributes' do
        let(:inserted){
          { a: 17, b: 18 }
        }

        it 'removes them and insert on operand' do
          expect(operand).to receive(:insert){|t|
            expect(t).to eql(a: 17)
            :yep
          }
          expect(subject).to eql(:yep)
        end
      end

    end
  end
end

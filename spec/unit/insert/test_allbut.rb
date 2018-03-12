require 'spec_helper'
module Bmg
  module Operator
    describe Allbut, "Insert logic" do

      let(:allbut){
        Allbut.new(Type::ANY, operand, [:b])
      }

      let(:operand){
        Object.new
      }

      subject{ allbut.insert(inserted) }

      context 'with a tuple not having allbuted attributes' do
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

      context 'with an enumerable not having allbuted attributes' do
        let(:inserted){
          [{ a: 17 }]
        }

        it 'inserts it on operand' do
          expect(operand).to receive(:insert){|t|
            expect(t).to eql([{a: 17}])
            :yep
          }
          expect(subject).to eql(:yep)
        end
      end

      context 'with a tuple exposing allbuted attributes' do
        let(:inserted){
          { a: 17, b: 18 }
        }

        it 'fails' do
          expect(operand).not_to receive(:insert)
          expect{ subject }.to raise_error(InvalidUpdateError)
        end
      end

    end
  end
end

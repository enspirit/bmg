require 'spec_helper'
module Bmg
  module Operator
    describe Project, "Insert logic" do

      let(:project_op){
        Project.new(Type::ANY, operand, [:a])
      }

      let(:operand){
        Object.new
      }

      subject{ project_op.insert(inserted) }

      context 'with a tuple having projected attributes only' do
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

      context 'with an enumerable having projected attributes only' do
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

      context 'with a tuple exposing non-projected attributes' do
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

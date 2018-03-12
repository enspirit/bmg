require 'spec_helper'
module Bmg
  module Operator
    describe Constants, "Update logic" do

      let(:constants){
        Constants.new(Type::ANY, operand, { b: 12 })
      }

      let(:operand){
        Object.new
      }

      subject{ constants.update(updated) }

      context 'with a valid tuple' do
        let(:updated){
          { a: 1 }
        }

        it 'lets it pass' do
          expect(operand).to receive(:update){|t|
            expect(t).to eql(a: 1)
            :yep
          }
          expect(subject).to eql(:yep)
        end
      end

      context 'when trying to update with a constant attribute while providing the good value' do
        let(:updated){
          { a: 1, b: 12 }
        }

        it 'removes them silently' do
          expect(operand).to receive(:update){|t|
            expect(t).to eql(a: 1)
            :yep
          }
          expect(subject).to eql(:yep)
        end
      end

      context 'when trying to update with a constant attribute while providing a wrong value' do
        let(:updated){
          { a: 1, b: 17 }
        }

        it 'raises an error' do
          expect(operand).not_to receive(:update)
          expect{ subject }.to raise_error(InvalidUpdateError)
        end
      end

    end
  end
end

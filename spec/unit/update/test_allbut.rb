require 'spec_helper'
module Bmg
  module Operator
    describe Allbut, "Update logic" do

      let(:allbut){
        Allbut.new(Type::ANY, operand, [:b])
      }

      let(:operand){
        Object.new
      }

      subject{ allbut.update(updated) }

      context 'with a valid tuple' do
        let(:updated){
          { a: 1 }
        }

        it 'let it pass' do
          expect(operand).to receive(:update){|t|
            expect(t).to eql(a: 1)
            :yep
          }
          expect(subject).to eql(:yep)
        end
      end

      context 'when trying to cheat' do
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

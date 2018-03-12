require 'spec_helper'
module Bmg
  module Operator
    describe Project, "Update logic" do

      let(:project_op){
        Project.new(Type::ANY, operand, [:a])
      }

      let(:operand){
        Object.new
      }

      subject{ project_op.update(updated) }

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

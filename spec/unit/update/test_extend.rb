require 'spec_helper'
module Bmg
  module Operator
    describe Extend, "Update logic" do

      let(:extend_op){
        Extend.new(Type::ANY, operand, { b: ->(t){ 12 } })
      }

      let(:operand){
        Object.new
      }

      subject{ extend_op.update(updated) }

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

      context 'when trying to update the extension attributes' do
        let(:updated){
          { a: 1, b: 17 }
        }

        it 'removes them silently' do
          expect(operand).to receive(:update){|t|
            expect(t).to eql(a: 1)
            :yep
          }
          expect(subject).to eql(:yep)
        end
      end

    end
  end
end

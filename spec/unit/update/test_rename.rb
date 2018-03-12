require 'spec_helper'
module Bmg
  module Operator
    describe Rename, "Update logic" do

      let(:rename){
        Rename.new(Type::ANY, operand, { :a => :b })
      }

      let(:operand){
        Object.new
      }

      subject{ rename.update(updated) }

      context 'with a tuple' do
        let(:updated){
          { b: 1 }
        }

        it 'renames it the other way round' do
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

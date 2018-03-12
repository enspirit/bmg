require 'spec_helper'
module Bmg
  module Operator
    describe Rename, "Insert logic" do

      let(:rename){
        Rename.new(Type::ANY, operand, { :a => :b })
      }

      let(:operand){
        Object.new
      }

      subject{ rename.insert(inserted) }

      context 'with a tuple' do
        let(:inserted){
          { b: 1 }
        }

        it 'renames it the other way round' do
          expect(operand).to receive(:insert){|t|
            expect(t).to eql(a: 1)
            :yep
          }
          expect(subject).to eql(:yep)
        end
      end

      context 'with an array' do
        let(:inserted){[
          { b: 1 },
          { b: 2 }
        ]}

        it 'renames them the other way round' do
          expect(operand).to receive(:insert){|t|
            expect(t).to eql([{a: 1},{a: 2}])
            :yep
          }
          expect(subject).to eql(:yep)
        end
      end

      context 'with a Relation' do
        let(:inserted){
          Leaf.new Type::ANY, [
            { b: 1 },
            { b: 2 }
          ]
        }

        it 'renames them the other way round' do
          expect(operand).to receive(:insert){|t|
            expect(t).to be_a(Operator::Rename)
            expect(t.send(:renaming)).to eql({:b => :a})
            :yep
          }
          expect(subject).to eql(:yep)
        end
      end

    end
  end
end

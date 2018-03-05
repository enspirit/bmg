require 'spec_helper'
module Bmg
  module Operator
    describe Union do

      let(:left) {
        [
          { a: 1 },
          { a: 2 }
        ]
      }

      let(:right) {
        [
          { a: 1 },
          { a: 3 }
        ]
      }

      it 'removes duplicates by default' do
        allbut = Union.new(Type::ANY, left, right)
        expect(allbut.to_a).to eql([{ a: 1 },{ a: 2 },{ a: 3 }])
      end

      it 'can be used for union_all too' do
        allbut = Union.new(Type::ANY, left, right, all: true)
        expect(allbut.to_a).to eql([{ a: 1 },{ a: 2 },{ a: 1 },{ a: 3 }])
      end

    end
  end
end

require 'spec_helper'
module Bmg
  module Operator
    describe Union do

      let(:r1) {
        [
          { a: 1 },
          { a: 2 }
        ]
      }

      let(:r2) {
        [
          { a: 1 },
          { a: 3 },
          { a: 4 }
        ]
      }

      let(:r3) {
        [
          { a: 1 },
          { a: 3 },
          { a: 5 }
        ]
      }

      it 'removes duplicates by default' do
        allbut = Union.new(Type::ANY, [r1, r2, r3])
        expect(allbut.to_a).to eql([{ a: 1 },{ a: 2 },{ a: 3 },{ a: 4 },{ a: 5 }])
      end

      it 'can be used for union_all too' do
        allbut = Union.new(Type::ANY, [r1, r2, r3], all: true)
        expect(allbut.to_a).to eql(r1 + r2 + r3)
      end

    end
  end
end

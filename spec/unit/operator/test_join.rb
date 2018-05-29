require 'spec_helper'
module Bmg
  module Operator
    describe Join do

      let(:left) {
        [
          { a: 1, b: 1, x: "a" },
          { a: 1, b: 2, x: "b" },
          { a: 2, b: 7, x: "c" }
        ]
      }

      let(:right) {
        [
          { a: 1, c: 8,  x: "8"  },
          { a: 1, c: 9,  x: "9"  },
          { a: 3, c: 10, x: "10" }
        ]
      }

      it 'works and ignores the shared :x attribute' do
        expected = [
          { a: 1, b: 1, c: 8, x: "a" },
          { a: 1, b: 1, c: 9, x: "a" },
          { a: 1, b: 2, c: 8, x: "b" },
          { a: 1, b: 2, c: 9, x: "b" },
        ]
        op = Join.new Type::ANY, left, right, [:a]
        expect(op.to_a). to eql(expected)
      end

      it 'works when result is empty' do
        op = Join.new Type::ANY, left, right, [:a, :x]
        expect(op.to_a). to eql([])
      end

    end
  end
end

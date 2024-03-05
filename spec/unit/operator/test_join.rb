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

      it 'supports a left_join variant' do
        expected = [
          { a: 1, b: 1, c:  8, x: "a" },
          { a: 1, b: 1, c:  9, x: "a" },
          { a: 1, b: 2, c:  8, x: "b" },
          { a: 1, b: 2, c:  9, x: "b" },
          { a: 2, b: 7, c: 10, x: "c" },
        ]
        op = Join.new Type::ANY, left, right, [:a], {
          :variant => :left,
          :default_right_tuple => { c: 10 }
        }
        expect(op.to_a).to eql(expected)
      end

      context 'without join list an no overlapping attributes' do
        let(:left) {
          [
            { a: 1, b: 2, x: "a" },
            { a: 3, b: 4, x: "b" },
          ]
        }

        let(:right) {
          [
            { q: 10, p: "80" },
            { q: 20, p: "90" },
          ]
        }

        it 'does a cross join' do
          expected = [
            { a: 1, b: 2, x: "a", q: 10, p: "80"},
            { a: 1, b: 2, x: "a", q: 20, p: "90"},
            { a: 3, b: 4, x: "b", q: 10, p: "80"},
            { a: 3, b: 4, x: "b", q: 20, p: "90"},
          ].to_set

          op = Join.new Type::ANY, left, right, []
          expect(op.to_set).to eql(expected)
        end
      end

      context 'without join list and shared attributes' do
        let(:left) {
          [
            { a: 1, b: 2, x: "a" },
            { a: 3, b: 4, x: "b" },
          ]
        }

        let(:right) {
          [
            { a: 1, q: 10, p: "80" },
            { a: 5, q: 20, p: "90" },
          ]
        }

        it 'does a cross join, discaring the shared attribute from right' do
          expected = [
            { a: 1, b: 2, x: "a", q: 10, p: "80"},
            { a: 1, b: 2, x: "a", q: 20, p: "90"},
            { a: 3, b: 4, x: "b", q: 10, p: "80"},
            { a: 3, b: 4, x: "b", q: 20, p: "90"},
          ].to_set

          op = Join.new Type::ANY, left, right, []
          expect(op.to_set).to eql(expected)
        end
      end

    end
  end
end

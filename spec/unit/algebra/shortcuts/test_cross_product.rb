require 'spec_helper'
module Bmg
  module Algebra
    describe Shortcuts, "cross_product" do

      let(:left) {
        Relation.new([
          { a: "foo",  xyz: 1 },
          { a: "bar",  xyz: 2 }
        ], Type::ANY.with_attrlist([:xyz, :b]))
      }

      let(:right) {
        Relation.new([
          { c: "baz",  d: 3 },
          { c: "zap",  d: 4 }
        ], Type::ANY.with_attrlist([:c, :d]))
      }

      subject {
        left.cross_product(right)
      }

      it 'compiles as expected' do
        expect(subject).to be_a(Operator::Join)
        expect(left_operand(subject)).to be(left)
        expect(right_operand(subject)).to be(right)
        expect(subject.send(:on)).to eql([])
      end

      it 'works as expected' do
        expect(subject.to_set).to eql([
          { a: "bar", xyz: 2, c: "zap", d: 4 },
          { a: "foo", xyz: 1, c: "baz", d: 3 },
          { a: "foo", xyz: 1, c: "zap", d: 4 },
          { a: "bar", xyz: 2, c: "baz", d: 3 },
        ].to_set)
      end

      context 'with duplicate attributes' do
        let(:right) {
          Relation.new([
            { xyz: "baz",  d: 3 },
            { xyz: "zap",  d: 4 }
          ], Type::ANY.with_attrlist([:xyz, :d]))
        }

        it 'raises an error' do
          expect{
            left.cross_product(right)
          }.to raise_error(Bmg::TypeError, /Cross product incompatible.*xyz/)
        end
      end
    end
  end
end

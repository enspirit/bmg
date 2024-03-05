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

      it 'keeps working fine when left does not know its attrs' do
        result = left.with_type(Type::ANY).cross_product(right)
        expect(result.to_set).to eql([
          { a: "bar", xyz: 2, c: "zap", d: 4 },
          { a: "foo", xyz: 1, c: "baz", d: 3 },
          { a: "foo", xyz: 1, c: "zap", d: 4 },
          { a: "bar", xyz: 2, c: "baz", d: 3 },
        ].to_set)
      end

      it 'keeps working fine when right does not know its attrs' do
        result = left.cross_product(right.with_type(Type::ANY))
        expect(result.to_set).to eql([
          { a: "bar", xyz: 2, c: "zap", d: 4 },
          { a: "foo", xyz: 1, c: "baz", d: 3 },
          { a: "foo", xyz: 1, c: "zap", d: 4 },
          { a: "bar", xyz: 2, c: "baz", d: 3 },
        ].to_set)
      end

      context 'with duplicate attributes and typechecked type' do
        let(:right) {
          Relation.new([
            { xyz: "baz",  d: 3 },
            { xyz: "zap",  d: 4 }
          ], Type::ANY.with_attrlist([:xyz, :d]).with_typecheck)
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

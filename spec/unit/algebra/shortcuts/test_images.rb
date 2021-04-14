require 'spec_helper'
module Bmg
  module Algebra
    describe Shortcuts, "images" do

      let(:left) {
        Relation.new([
          { a: "foo",  b: 2 },
          { a: "bar",  b: 2 }
        ], Type::ANY.with_attrlist([:a, :b]))
      }

      let(:r1) {
        Relation.new([
          { a: "foo",  c: 4 },
          { a: "baz",  c: 4 }
        ], Type::ANY.with_attrlist([:z, :c]))
      }

      let(:r2) {
        Relation.new([
          { a: "bar",  d: 3 },
          { a: "baz",  d: 4 }
        ], Type::ANY.with_attrlist([:z, :c]))
      }

      subject {
        left.images({ :r1 => r1, :r2 => r2 }, [:a], array: true)
      }

      it 'compiles as expected' do
        expect(subject).to be_a(Operator::Image)
        expect(left_operand(subject)).to be_a(Operator::Image)
        expect(left_operand(left_operand(subject))).to be(left)
        expect(right_operand(left_operand(subject))).to be(r1)
        expect(right_operand(subject)).to be(r2)
      end

      it 'works as expected' do
        expect(subject.to_a).to eql([
          { a: "foo", b: 2, r1: [{c: 4}], r2: [] },
          { a: "bar", b: 2, r1: [], r2: [{d: 3}] }
        ])
      end

    end
  end
end

require 'spec_helper'
module Bmg
  module Algebra
    describe Shortcuts, "join" do

      let(:left) {
        Relation.new([
          { a: "foo",  b: 2 },
          { a: "bar",  b: 2 }
        ], Type::ANY.with_attrlist([:a, :b]))
      }

      let(:right) {
        Relation.new([
          { z: "foo",  c: 4 },
          { z: "baz",  c: 4 }
        ], Type::ANY.with_attrlist([:z, :c]))
      }

      subject {
        left.join(right, :a => :z)
      }

      it 'compiles as expected' do
        expect(subject).to be_a(Operator::Join)
        expect(left_operand(subject)).to be(left)
        expect(right_operand(subject)).to be_a(Operator::Rename)
        expect(right_operand(subject).send(:renaming)).to eql({:z => :a})
        expect(subject.send(:on)).to eql([:a])
      end

      it 'works as expected' do        
        expect(subject.to_a).to eql([
          { a: "foo", b: 2, c: 4 }
        ])
      end

    end
  end
end

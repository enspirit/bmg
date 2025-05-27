require 'spec_helper'
module Bmg
  module Operator
    describe Transform do

      it 'works' do
        extended = Transform.new Type::ANY, [{ a: 1 }], { a: ->(a){ a*2 } }
        expect(extended.to_a).to eql([{ a: 2 }])
      end

      it 'can be used to coerce a relation with a type' do
        transformer = Type.for_heading(a: Integer)
        extended = Transform.new(Type::ANY, [
          { a: "1" }
        ], transformer)
        expect(extended.to_a).to eql([
          { a: 1 }
        ])
      end

      it 'can be used to coerce a relation with a type and RVA' do
        transformer = Type.for_heading(as: Type.for_heading(a: Integer))
        extended = Transform.new(Type::ANY, [
          { as: { a: "1" } }
        ], transformer)
        expect(extended.to_a).to eql([
          { as: { a: 1 } }
        ])
      end

    end
  end
end

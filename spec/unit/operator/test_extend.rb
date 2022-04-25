require 'spec_helper'
module Bmg
  module Operator
    describe Extend do

      it 'works' do
        extended = Extend.new Type::ANY, [
          { a: 1 }
        ], {
          b: ->(t){ 2 }
        }
        expect(extended.to_a).to eql([{ a: 1, b: 2}])
      end

      it 'works with a symbol' do
        extended = Extend.new Type::ANY, [
          { a: 1 }
        ], {
          b: :a
        }
        expect(extended.to_a).to eql([{ a: 1, b: 1 }])
      end

    end
  end
end

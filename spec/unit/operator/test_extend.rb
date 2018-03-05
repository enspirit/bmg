require 'spec_helper'
module Bmg
  module Operator
    describe Extend do

      it 'works' do
        extended = Extend.new Type::ANY, [{ a: 1 }], { b: ->(t){ 2 } }
        expect(extended.to_a).to eql([{ a: 1, b: 2}])
      end

    end
  end
end

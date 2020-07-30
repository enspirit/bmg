require 'spec_helper'
module Bmg
  module Operator
    describe Transform do

      it 'works' do
        extended = Transform.new Type::ANY, [{ a: 1 }], { a: ->(a){ a*2 } }
        expect(extended.to_a).to eql([{ a: 2 }])
      end

    end
  end
end

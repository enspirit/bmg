require 'spec_helper'
module Bmg
  module Operator
    describe Constants do

      it 'works' do
        extended = Constants.new Type::ANY, [{ a: 1 }], { b: 2 }
        expect(extended.to_a).to eql([{ a: 1, b: 2 }])
      end

    end
  end
end

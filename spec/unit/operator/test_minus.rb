require 'spec_helper'
module Bmg
  module Operator
    describe Minus do

      let(:r1) {
        [
          { a: 1 },
          { a: 2 },
          { a: 3 },
          { a: 4 },
          { a: 5 }
        ]
      }

      let(:r2) {
        [
          { a: 1 },
          { a: 4 }
        ]
      }

      let(:r3) {
        [
          { a: 3 }
        ]
      }

      it 'works' do
        difference = Minus.new(Type::ANY, [r1, r2, r3])
        expect(difference.to_a).to eql([{ a: 2 },{ a: 5 }])
      end

    end
  end
end

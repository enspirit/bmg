require 'spec_helper'
module Bmg
  module Operator
    describe Restrict do

      it 'works' do
        restricted = Restrict.new [
          { a: 1,  b: 2 },
          { a: 11, b: 2 }
        ], Predicate.gt(:a, 10)
        expect(restricted.to_a).to eql([{ a: 11, b: 2 }])
      end

    end
  end
end

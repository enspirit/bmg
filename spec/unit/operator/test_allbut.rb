require 'spec_helper'
module Bmg
  module Operator
    describe Allbut do

      it 'works' do
        allbut = Allbut.new [{ a: 1, b: 2 }], [:b]
        expect(allbut.to_a).to eql([{ a: 1 }])
      end

      it 'removes duplicates' do
        allbut = Allbut.new [{ a: 1, b: 2 }, { a: 1, b: 3 }], [:b]
        expect(allbut.to_a).to eql([{ a: 1 }])
      end

    end
  end
end

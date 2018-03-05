require 'spec_helper'
module Bmg
  module Operator
    describe Project do

      it 'works' do
        allbut = Project.new Type::ANY, [{ a: 1, b: 2 }], [:b]
        expect(allbut.to_a).to eql([{ b: 2 }])
      end

      it 'removes duplicates' do
        allbut = Project.new Type::ANY, [{ a: 1, b: 2 }, { a: 2, b: 2 }], [:b]
        expect(allbut.to_a).to eql([{ b: 2 }])
      end

    end
  end
end

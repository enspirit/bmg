require 'spec_helper'
module Bmg
  module Operator
    describe Rename do

      it 'works' do
        rename = Rename.new Type::ANY, [{ a: 1, b: 2 }], :a => :x
        expect(rename.to_a).to eql([{ x: 1, b: 2 }])
      end

    end
  end
end

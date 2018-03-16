require 'spec_helper'
module Bmg
  describe "The spying mechanism" do

    it 'lets install a main spy that applies to all relations' do
      seen = []
      Bmg.main_spy = ->(r) {
        seen << r
      }

      r = Relation.new([{a: 1},{a: 2}]).restrict(a: 2)
      expect(r.to_a).to eql([{a: 2}])

      expect(seen).to eql([r])
    end

  end
end

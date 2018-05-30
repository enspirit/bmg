require 'spec_helper'
module Bmg
  describe "shared optimization" do

    let(:a_relation) {
      Relation.new([{a: 1}])
    }

    let(:empty) {
      Relation.empty
    }

    it "includes the fact that any relation returns self if unioned with empty" do
      expect(a_relation.union(empty)).to be(a_relation)
    end

  end
end

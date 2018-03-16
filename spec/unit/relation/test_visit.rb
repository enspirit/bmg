require 'spec_helper'
module Bmg
  describe Relation, "visit" do

    let(:first) {
      Relation.new [
        { a: 1, b: 1, order: 5 },
        { a: 1, b: 2, order: 2 }
      ]
    }

    let(:second) {
      Relation.new [
        { a: 1, b: 3, order: 3 },
        { a: 2, b: 1, order: 1 },
        { a: 1, b: 2, order: 1 }
      ]
    }    

    let(:third) {
      Relation.new [
        { a: 1, c: 3 }
      ]
    }    

    let(:expr) {
      first.union(second).image(third, :image, [:a]).restrict(a: 1)
      # first.restrict(a: 1).union(second.restrict(a: 1)).image(third.restrict(a: 1))
    }

    it 'visits them all, taking optimization into account' do
      seen = []
      expr.visit{|rel, parent|
        seen << [rel, parent] 
      }
      expect(seen[0][0]).to be_a(Operator::Image)
      expect(seen[0][1]).to be_nil
      expect(seen[1][0]).to be_a(Operator::Union)
      expect(seen[1][1]).to be_a(Operator::Image)
      expect(seen[2][0]).to be_a(Operator::Restrict)
      expect(seen[2][1]).to be_a(Operator::Union)
      expect(seen[3][0]).to be(first)
      expect(seen[3][1]).to be_a(Operator::Restrict)
      expect(seen[4][0]).to be_a(Operator::Restrict)
      expect(seen[4][1]).to be_a(Operator::Union)
      expect(seen[5][0]).to be(second)
      expect(seen[5][1]).to be_a(Operator::Restrict)
      expect(seen[6][0]).to be_a(Operator::Restrict)
      expect(seen[6][1]).to be_a(Operator::Image)
      expect(seen[7][0]).to be(third)
      expect(seen[7][1]).to be_a(Operator::Restrict)
    end

  end
end
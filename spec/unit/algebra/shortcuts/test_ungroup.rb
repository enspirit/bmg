require 'spec_helper'
module Bmg
  module Algebra
    describe Shortcuts, "ungroup" do

      let(:relation) {
        Relation.new([
          { :a => "foo", :c => [{:b => 2}, {:b => 3}] },
          { :a => "bar", :c => [{:b => 2}] }
        ])
      }

      subject {
        relation.ungroup(:c)
      }

      it 'works as expected' do
        expect(subject.to_a).to eql([
          { a: "foo", b: 2 },
          { a: "foo", b: 3 },
          { a: "bar", b: 2 }
        ])
      end

    end
  end
end

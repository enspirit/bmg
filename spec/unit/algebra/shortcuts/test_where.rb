require 'spec_helper'
module Bmg
  module Algebra
    describe Shortcuts, "where" do

      let(:relation) {
        Relation.new([
          { a: "foo",  b: 2 },
          { a: "bar",  b: 2 }
        ], Type::ANY.with_attrlist([:a, :b]))
      }

      subject {
        relation.where(:a => "foo")
      }

      it 'works as expected' do
        expect(subject.to_a).to eql([
          { a: "foo",  b: 2 }
        ])
      end

    end
  end
end

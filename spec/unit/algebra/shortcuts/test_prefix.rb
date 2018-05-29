require 'spec_helper'
module Bmg
  module Algebra
    describe Shortcuts, "prefix" do

      let(:data) {
        [
          { a: "foo",  b: 2 },
          { a: "bar",  b: 2 }
        ]
      }

      subject {
        Relation.new(data, Type::ANY.with_attrlist([:a, :b])).prefix(:foo_)
      }

      it 'works as expected' do
        expect(subject.to_a).to eql([
          { foo_a: "foo",  foo_b: 2 },
          { foo_a: "bar",  foo_b: 2 }
        ])
      end

    end
  end
end

require 'spec_helper'
module Bmg
  module Algebra
    describe Shortcuts, "suffix" do

      let(:data) {
        [
          { a: "foo",  b: 2 },
          { a: "bar",  b: 2 }
        ]
      }

      subject {
        Relation.new(data, Type::ANY.with_attrlist([:a, :b])).suffix(:_foo)
      }

      it 'works as expected' do
        expect(subject.to_a).to eql([
          { a_foo: "foo",  b_foo: 2 },
          { a_foo: "bar",  b_foo: 2 }
        ])
      end

    end
  end
end

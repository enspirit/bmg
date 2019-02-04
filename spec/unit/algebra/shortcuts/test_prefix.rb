require 'spec_helper'
module Bmg
  module Algebra
    describe Shortcuts, "prefix" do

      let(:relation) {
        Relation.new([
          { a: "foo",  b: 2 },
          { a: "bar",  b: 2 }
        ], Type::ANY.with_attrlist([:a, :b]))
      }

      context 'without options' do
        subject {
          relation.prefix(:foo_)
        }

        it 'works as expected' do
          expect(subject.to_a).to eql([
            { foo_a: "foo",  foo_b: 2 },
            { foo_a: "bar",  foo_b: 2 }
          ])
        end
      end

      context 'without a butlist option' do
        subject {
          relation.prefix(:foo_, :but => [:a])
        }

        it 'works as expected' do
          expect(subject.to_a).to eql([
            { a: "foo",  foo_b: 2 },
            { a: "bar",  foo_b: 2 }
          ])
        end
      end

    end
  end
end

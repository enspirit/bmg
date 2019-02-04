require 'spec_helper'
module Bmg
  module Algebra
    describe Shortcuts, "suffix" do

      let(:relation) {
        Relation.new([
          { a: "foo",  b: 2 },
          { a: "bar",  b: 2 }
        ], Type::ANY.with_attrlist([:a, :b]))        
      }

      context 'when used without option' do
        subject {
          relation.suffix(:_foo)
        }

        it 'works as expected' do
          expect(subject.to_a).to eql([
            { a_foo: "foo",  b_foo: 2 },
            { a_foo: "bar",  b_foo: 2 }
          ])
        end
      end

      context 'when used with a :but option' do
        subject {
          relation.suffix(:_foo, :but => [:a])
        }

        it 'works as expected' do
          expect(subject.to_a).to eql([
            { a: "foo",  b_foo: 2 },
            { a: "bar",  b_foo: 2 }
          ])
        end
      end

    end
  end
end

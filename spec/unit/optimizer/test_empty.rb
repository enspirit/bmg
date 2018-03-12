require 'spec_helper'
module Bmg
  describe "emty optimization" do

    let(:empty) {
      Relation::Empty.new(Type::ANY)
    }

    [
      [:allbut, []],
      [:autosummarize, []],
      [:autowrap, []],
      [:extend, []],
      [:image, [ Relation.new([]) ]],
      [:project, []],
      [:rename, [{}]],
      [:restrict, [Predicate.eq(a: 1)]]
    ].each do |(kind, args)|

      context "empty.#{kind}" do

        subject{
          empty.public_send(kind, *args)
        }

        it 'returns itself' do
          expect(subject).to be_a(Relation::Empty)
        end

      end

    end

    context 'empty.union' do

      let(:other) {
        Relation.new [{a: 1}]
      }

      subject{
        empty.union(other)
      }

      it 'returns other' do
        expect(subject).to be(other)
      end
    end

  end
end

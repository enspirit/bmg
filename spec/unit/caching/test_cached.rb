require 'spec_helper'
module Bmg
  module Relation
    describe Cached do

      class OneTime < Leaf
        def initialize(*args)
          super
          @index = 0
        end
        def each(&bl)
          raise unless @index == 0
          @index += 1
          super
        end
      end

      let(:cache) {
        Hash.new
      }

      let(:relation) {
        OneTime.new Type::ANY, [
          { sid: 1, pid: 1, qty: 10 },
          { sid: 1, pid: 2, qty: 25 },
          { sid: 3, pid: 1, qty: 5  },
          { sid: 4, pid: 4, qty: 7 }
        ]
      }

      let(:cached) {
        relation.cached([:sid], cache)
      }

      it 'does not put in cache unless key attributes are constant' do
        expect(cached.restrict(pid: 1).to_a.size).to eql(2)
        expect(cache).to be_empty
      end

      it 'does not put in cache if predicate is more restrictive' do
        expect(cached.restrict(sid: 1, pid: 1).to_a.size).to eql(1)
        expect(cache).to be_empty
      end

      it 'puts in cache when key attributes are constant' do
        expect(cached.restrict(sid: 1).to_a.size).to eql(2)
        expect(cache).not_to be_empty
        expect(cache.keys).to eql([{sid: 1}])
        expect(cached.restrict(sid: 1).to_a.size).to eql(2)
      end

      it 'correctly apply the predicate to the cached results' do
        cached.restrict(sid: 1).to_a
        expect(cache).not_to be_empty
        expect(cache.keys).to eql([{sid: 1}])
        expect(cached.restrict(sid: 1).restrict(pid: 1).to_a.size).to eql(1)
        expect(cached.restrict(sid: 1, pid: 1).to_a.size).to eql(1)
      end

    end
  end
end

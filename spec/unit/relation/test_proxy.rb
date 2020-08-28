require 'spec_helper'
require 'ostruct'
require 'json'
module Bmg
  module Relation
    describe Proxy do

      class ProxyTuple < OpenStruct
      end

      class ProxyTest
        include Proxy

        def _proxy_tuple(tuple)
          ProxyTuple.new(tuple)
        end
      end

      let(:rel) {
        Relation.new [{a: 1},{a: 2}]
      }

      subject{
        ProxyTest.new(rel)
      }

      it 'reproxies all algebra results' do
        got = subject.rename(:a => :b)
        expect(got).to be_a(ProxyTest)
        expect(got.to_a.first[:b]).to eql(1)
      end

      it 'reproxies extend too' do
        got = subject.extend(:b => ->(t){ t[:a] })
        expect(got).to be_a(ProxyTest)
        expect(got.to_a.first[:b]).to eql(1)
      end

      it 'proxies the tuple on one and one_or_nil' do
        got = subject.restrict(->(t){ t[:a] == 1 }).one
        expect(got).to be_a(ProxyTuple)

        got = subject.restrict(->(t){ false }).one_or_nil
        expect(got).to be_nil
      end

      it 'lets map too' do
        got = subject.map{|t| t[:a] }
        expect(got).to eql([1, 2])
      end

      it 'keeps to_json working' do
        got = JSON.parse(subject.to_json)
        expect(got).to eql([{"a" => 1},{"a" => 2}])
      end

    end
  end
end


require 'spec_helper'
module Bmg
  class Summarizer
    describe Percentile do

      let(:rel){[
        {:qty => 10},
        {:qty => 1},
        {:qty => 8},
        {:qty => 15},
        {:qty => 7}
      ]}

      it 'should work when used standalone' do
        expect(Percentile.new(:qty).summarize(rel)).to eql(7)
      end

      it 'should install factory methods' do
        expect(Summarizer.percentile(:qty)).to be_a(Percentile)
        expect(Summarizer.percentile(:qty).summarize(rel)).to eql(7)
        expect(Summarizer.percentile(:qty, 50).summarize(rel)).to eql(7)
        expect(Summarizer.median(:qty).summarize(rel)).to eql(7)
      end

      it 'lets specify nth' do
        expect(Percentile.new(:qty).summarize(rel)).to eql(7)
        expect(Percentile.new(:qty, 100).summarize(rel)).to eql(15)
        expect(Percentile.new(:qty, 0).summarize(rel)).to eql(1)
        expect(Percentile.new(:qty, 80).summarize(rel)).to eql(10)
      end

      it 'lets specify nth with a block' do
        expect(Percentile.new{|t| t[:qty] }.summarize(rel)).to eql(7)
        expect(Percentile.new(80){|t| t[:qty] }.summarize(rel)).to eql(10)
      end

    end
  end
end

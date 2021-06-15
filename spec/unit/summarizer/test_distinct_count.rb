require 'spec_helper'
module Bmg
  class Summarizer
    describe DistinctCount do

      let(:rel){[
        {:qty => 10},
        {:qty => 20},
        {:qty => 20},
        {:qty => 40}
      ]}

      it 'has correct name' do
        expect(DistinctCount.new(:qty).to_summarizer_name).to eql(:distinct_count)
      end

      it 'should work when used standalone' do
        expect(DistinctCount.new(:qty).summarize([])).to eql(0)
        expect(DistinctCount.new(:qty).summarize(rel)).to eql(3)
      end

      it 'should install factory methods' do
        expect(Summarizer.distinct_count(:qty)).to be_a(DistinctCount)
        expect(Summarizer.distinct_count(:qty).summarize(rel)).to eql(3)
      end

    end
  end
end

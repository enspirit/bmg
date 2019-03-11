require 'spec_helper'
module Bmg
  class Summarizer
    describe Stddev do

      let(:rel){[
        {:qty => 10}, 
        {:qty => 20},
        {:qty => 30},
        {:qty => 40}
      ]}
      let(:expected) {
        Math.sqrt(Variance.new(:qty).summarize(rel))
      }

      it 'should work when used standalone' do
        expect(Stddev.new(:qty).summarize(rel)).to eql(expected)
      end

      it 'should install factory methods' do
        expect(Summarizer.stddev(:qty)).to be_a(Stddev)
        expect(Summarizer.stddev(:qty).summarize(rel)).to eql(expected)
      end

    end
  end
end 

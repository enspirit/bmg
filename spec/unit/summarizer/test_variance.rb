require 'spec_helper'
module Bmg
  class Summarizer
    describe Variance do

      let(:rel){[
        {:qty => 10}, 
        {:qty => 20},
        {:qty => 30},
        {:qty => 40}
      ]}
      let(:expected) {
        vals = rel.map{|t| t[:qty]}
        mean = vals.inject(:+) / vals.size.to_f
        vals.collect{|v| (v - mean)**2 }.inject(:+) / vals.size.to_f
      }

      it 'should work when used standalone' do
        expect(Variance.new(:qty).summarize(rel)).to eql(expected)
      end

      it 'should install factory methods' do
        expect(Summarizer.variance(:qty)).to be_a(Variance)
        expect(Summarizer.variance(:qty).summarize(rel)).to eql(expected)
      end

    end
  end
end 

require 'spec_helper'
module Bmg
  class Summarizer
    describe Collect do

      let(:rel){[
        {:qty => 10}, 
        {:qty => 20},
        {:qty => 30},
        {:qty => 40}
      ]}

      it 'should work when used standalone' do
        expect(Collect.new(:qty).summarize([])).to eql([])
        expect(Collect.new(:qty).summarize(rel)).to eql([10,20,30,40])
      end

      it 'should install factory methods' do
        expect(Summarizer.collect(:qty)).to be_a(Collect)
        expect(Summarizer.collect(:qty).summarize(rel)).to eql([10,20,30,40])
      end

    end
  end
end 

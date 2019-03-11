require 'spec_helper'
module Bmg
  class Summarizer
    describe Avg do

      let(:rel){[
        {:qty => 10}, 
        {:qty => 1}
      ]}

      it 'should work when used standalone' do
        expect(Avg.new(:qty).summarize(rel)).to eql(5.5)
      end

      it 'should install factory methods' do
        expect(Summarizer.avg(:qty)).to be_a(Avg)
        expect(Summarizer.avg(:qty).summarize(rel)).to eql(5.5)
      end

    end
  end
end 

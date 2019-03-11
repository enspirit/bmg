require 'spec_helper'
module Bmg
  class Summarizer
    describe Sum do

      let(:rel){[
        {:qty => 10}, 
        {:qty => 20}
      ]}

      it 'should work when used standalone' do
        expect(Sum.new(:qty).summarize([])).to eql(0)
        expect(Sum.new(:qty).summarize(rel)).to eql(30)
      end

      it 'should install factory methods' do
        expect(Summarizer.sum(:qty)).to be_a(Sum)
        expect(Summarizer.sum(:qty).summarize(rel)).to eql(30)
      end

    end
  end
end 

require 'spec_helper'
module Bmg
  class Summarizer
    describe Max do

      let(:rel){[
        {:qty => 10}, 
        {:qty => 0}
      ]}

      it 'should work when used standalone' do
        expect(Max.new(:qty).summarize([])).to eql(nil)
        expect(Max.new(:qty).summarize(rel)).to eql(10)
      end

      it 'should install factory methods' do
        expect(Summarizer.max(:qty)).to be_a(Max)
        expect(Summarizer.max(:qty).summarize(rel)).to eql(10)
      end

    end
  end
end 

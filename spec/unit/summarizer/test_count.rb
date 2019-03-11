require 'spec_helper'
module Bmg
  class Summarizer
    describe Count do

      it 'should work when used standalone' do
        expect(Count.new.summarize([])).to eql(0)
        expect(Count.new.summarize([{}])).to eql(1)
      end

      it 'should install factory methods' do
        expect(Summarizer.count).to be_a(Count)
      end

    end
  end
end 

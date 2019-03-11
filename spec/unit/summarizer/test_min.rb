require 'spec_helper'
module Bmg
  class Summarizer
    describe Min do

      let(:rel){[
        {:qty => 10}, 
        {:qty => 0}
      ]}

      it 'should work when used standalone' do
        expect(Min.new(:qty).summarize([])).to eql(nil)
        expect(Min.new(:qty).summarize(rel)).to eql(0)
      end

      it 'should install factory methods' do
        expect(Summarizer.min(:qty)).to be_a(Min)
        expect(Summarizer.min(:qty).summarize(rel)).to eql(0)
      end

    end
  end
end 

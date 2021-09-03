require 'spec_helper'
module Bmg
  class Summarizer
    describe First do

      let(:rel){[
        {:rownum => 1, :qty => 10},
        {:rownum => 2, :qty => 11}
      ]}

      it 'raises when order is missing' do
        expect{
          First.new(:qty).summarize([])
        }.to raise_error(ArgumentError)
      end

      it 'should work' do
        args = [:qty, :order => [:rownum]]
        expect(First.new(*args).summarize([])).to eql(nil)
        expect(First.new(*args).summarize(rel)).to eql(10)
        args = [:qty, :order => [[:rownum, :desc]]]
        expect(First.new(*args).summarize(rel)).to eql(11)
      end

      it 'should install factory methods' do
        args = [:qty, :order => [:rownum]]
        expect(Summarizer.first(*args)).to be_a(First)
        expect(Summarizer.first(*args).summarize(rel)).to eql(10)
      end

    end
  end
end 

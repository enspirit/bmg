require 'spec_helper'
module Bmg
  class Summarizer
    describe Last do

      let(:rel){[
        {:rownum => 1, :qty => 10},
        {:rownum => 2, :qty => 11}
      ]}

      it 'raises when order is missing' do
        expect{
          Last.new(:qty).summarize([])
        }.to raise_error(ArgumentError)
      end

      it 'should work' do
        args = [:qty, :order => [:rownum]]
        expect(Last.new(*args).summarize([])).to eql(nil)
        expect(Last.new(*args).summarize(rel)).to eql(11)
        args = [:qty, :order => [[:rownum, :desc]]]
        expect(Last.new(*args).summarize(rel)).to eql(10)
      end

      it 'should install factory methods' do
        args = [:qty, :order => [:rownum]]
        expect(Summarizer.last(*args)).to be_a(Last)
        expect(Summarizer.last(*args).summarize(rel)).to eql(11)
      end

    end
  end
end 

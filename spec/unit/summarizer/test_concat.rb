require 'spec_helper'
module Bmg
  class Summarizer
    describe Concat do

      let(:rel){[
        {:qty => 10}, 
        {:qty => 20},
        {:qty => 30},
        {:qty => 40}
      ]}

      it 'should work when used standalone' do
        expect(Concat.new(:qty).summarize([])).to eql("")
        expect(Concat.new(:qty).summarize(rel)).to eql("10203040")
      end

      it 'should work when used standalone with Proc of arity 1' do
        expect(Concat.new{|t| t[:qty] }.summarize(rel)).to eql("10203040")
      end

      it 'should work when used standalone with Proc of arity 1 passed as arg' do
        expect(Concat.new(->(t){ t[:qty] }).summarize(rel)).to eql("10203040")
      end

      it 'should install factory methods' do
        expect(Summarizer.concat(:qty)).to be_a(Concat)
        expect(Summarizer.concat(:qty).summarize(rel)).to eql("10203040")
      end

      it 'should work with options' do
        options = {:before => "bef", :after => "aft", :between => " bet "}
        expected = "bef10 bet 20 bet 30 bet 40aft"
        expect(Summarizer.concat(:qty, options).summarize(rel)).to eql(expected)
      end

    end
  end
end 

require 'spec_helper'
module Bmg
  class Summarizer
    describe Distinct do

      let(:rel){[
        {:qty => 10},
        {:qty => 20},
        {:qty => 20},
        {:qty => 40}
      ]}

      it 'should work when used standalone' do
        expect(Distinct.new(:qty).summarize([])).to eql([])
        expect(Distinct.new(:qty).summarize(rel)).to eql([10,20,40])
      end

      it 'should install factory methods' do
        expect(Summarizer.distinct(:qty)).to be_a(Distinct)
        expect(Summarizer.distinct(:qty).summarize(rel)).to eql([10,20,40])
      end

    end
  end
end

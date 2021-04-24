require 'spec_helper'
module Bmg
  class Summarizer
    describe ByProc do

      let(:rel){[
        {:qty => 10},
        {:qty => 20},
        {:qty => 20},
        {:qty => 40}
      ]}

      let(:p){
        ->(t,memo){
          (memo||0)+t[:qty]
        }
      }

      it 'should work when used standalone' do
        expect(ByProc.new(0, p).summarize([])).to eql(0)
        expect(ByProc.new(0, p).summarize(rel)).to eql(90)
      end

      it 'install factory methods that behave as expected' do
        expect(Summarizer.by_proc(&p)).to be_a(ByProc)
        expect(Summarizer.by_proc(&p).summarize(rel)).to eql(90)
        expect(Summarizer.by_proc(p).summarize(rel)).to eql(90)
        expect(Summarizer.by_proc(0, p).summarize(rel)).to eql(90)
        expect(Summarizer.by_proc(10, p).summarize(rel)).to eql(100)
        expect(Summarizer.by_proc(10, &p).summarize(rel)).to eql(100)
      end

    end
  end
end

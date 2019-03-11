require 'spec_helper'
module Bmg
  module Operator
    describe Summarize do

      let(:data) {
        [
          { a: 1,  b: 2 },
          { a: 11, b: 2 }
        ]
      }

      context 'with an empty by' do
        subject {
          Summarize.new Type::ANY, data, [], {
            :count => :count,
            :b     => :sum,
            :sum_b => Bmg::Summarizer.sum(:b),
            :avg_a_times_b => Bmg::Summarizer.avg{|t| t[:a]*t[:b] },
          }
        }

        it 'works' do
          expect(subject.to_a).to eql([
            {
              :count => 2,
              :b => 4,
              :sum_b => 4,
              :avg_a_times_b => 12.0
            }
          ])
        end
      end

      context 'with an non empty by' do
        subject {
          Summarize.new Type::ANY, data, [:b], {
            :count => :count,
            :a => :sum
          }
        }

        it 'works' do
          expect(subject.to_a).to eql([
            {
              :b => 2,
              :a => 12,
              :count => 2
            }
          ])
        end
      end

    end
  end
end

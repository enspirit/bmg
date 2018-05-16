require 'spec_helper'
module Bmg
  module Operator
    describe Restrict do

      let(:data) {
        [
          { a: "foo",  b: 2 },
          { a: "bar",  b: 2 }
        ]
      }

      let(:options) {
        {}
      }

      subject {
        Rxmatch.new Type::ANY, data, attrs, matcher, options
      }

      context 'against a string' do
        let(:attrs){ [:a] }
        let(:matcher){ "fo" }

        it 'works as expected' do
          expect(subject.to_a).to eql([
            { a: "foo",  b: 2 }
          ])
        end
      end

      context 'against a string, it is case insensitive by default' do
        let(:attrs){ [:a] }
        let(:matcher){ "Fo" }

        it 'works as expected' do
          expect(subject.to_a).to eql([
            { a: "foo",  b: 2 }
          ])
        end
      end

      context 'against a string, it is case sensitive if requested' do
        let(:attrs){ [:a] }
        let(:matcher){ "Fo" }
        let(:options){ { case_sensitive: true } }

        it 'works as expected' do
          expect(subject.to_a).to eql([
          ])
        end
      end

      context 'against a string targetting an integer' do
        let(:attrs){ [:b] }
        let(:matcher){ "2" }

        it 'works as expected' do
          expect(subject.to_a).to eql([
            { a: "foo",  b: 2 },
            { a: "bar",  b: 2 }
          ])
        end
      end

      context 'when including multiple attributes and using a regexp' do
        let(:attrs){ [:a, :b] }
        let(:matcher){ /foo/ }

        it 'works as expected' do
          expect(subject.to_a).to eql([
            { a: "foo",  b: 2 }
          ])
        end
      end

    end
  end
end

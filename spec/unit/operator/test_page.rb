require 'spec_helper'
module Bmg
  module Operator
    describe Page do

      let(:operand) {
        (1...100).map{|i|
          { a: i, b: 100-i }
        }
      }

      subject {
        Page.new(Type::ANY, operand, ordering, page_index, page_size: page_size)
      }

      let(:page_size){ 2 }

      context 'with an ordering on :a' do
        let(:ordering) { [:a] }

        context 'with the first page' do
          let(:page_index){ 1 }

          it 'works' do
            expect(subject.to_a).to eql([
              { a: 1, b: 99 },
              { a: 2, b: 98 }
            ])
          end
        end

        context 'with the second page' do
          let(:page_index){ 2 }

          it 'works' do
            expect(subject.to_a).to eql([
              { a: 3, b: 97 },
              { a: 4, b: 96 }
            ])
          end
        end

        context 'with a different page size' do
          let(:page_index){ 1 }
          let(:page_size){ 5 }

          it 'works' do
            expect(subject.to_a).to eql([
              { a: 1, b: 99 },
              { a: 2, b: 98 },
              { a: 3, b: 97 },
              { a: 4, b: 96 },
              { a: 5, b: 95 }
            ])
          end
        end

      end

      context 'with an ordering on :b' do
        let(:ordering) { [:b] }

        context 'with the first page' do
          let(:page_index){ 1 }

          it 'works' do
            expect(subject.to_a).to eql([
              { a: 99, b: 1 },
              { a: 98, b: 2 }
            ])
          end
        end
      end

      context 'with a descending ordering on :a' do
        let(:ordering) { [[:a, :desc]] }

        context 'with the first page' do
          let(:page_index){ 1 }

          it 'works' do
            expect(subject.to_a).to eql([
              { a: 99, b: 1 },
              { a: 98, b: 2 }
            ])
          end
        end
      end

    end
  end
end

require 'spec_helper'
module Bmg
  module Operator
    describe Image do

      subject {
        Image.new(Type::ANY, left, right, :values, on, options)
      }

      context 'with a single attribute as shared key' do

        let(:on){ [:id] }

        let(:left) {
          Relation.new([
            { id: 1, label: "Main 1" },
            { id: 2, label: "Main 2" }
          ])
        }

        let(:right) {
          Relation.new([
            { id: 1, x: "foo", y: "hello" },
            { id: 1, x: "bar", y: "world" }
          ])
        }

        let(:expected) {
          Relation.new([
            {
              id: 1,
              label: "Main 1",
              values: [
                { x: "foo", y: "hello" },
                { x: "bar", y: "world" }
              ]
            },
            {
              id: 2,
              label: "Main 2",
              values: [
              ]
            }
          ])
        }

        context 'with option to convert to an array' do
          let(:options) { { array: true } }

          it 'works' do
            expect(subject.to_a).to eql(expected.to_a)
          end
        end

        context 'with option refilter_right strategy' do
          let(:options) { { array: true, strategy: :refilter_right } }

          it 'works' do
            expect(subject.to_a).to eql(expected.to_a)
          end
        end

        context 'without the option' do
          let(:options) { {  } }

          it 'keeps relation as values' do
            expect(subject.to_a.all?{|t| t[:values].is_a?(Relation) }).to be(true)
          end

        end
      end

      context 'with a single attribute as shared key' do
        let(:on){ [:id, :label] }
        let(:options) { { array: true } }

        let(:left) {
          Relation.new([
            { id: 1, label: "Main 1" },
            { id: 2, label: "Main 2" }
          ])
        }

        let(:right) {
          Relation.new([
            { id: 1, label: "Main 1", y: "hello" },
            { id: 1, label: "Main 2", y: "world" }
          ])
        }

        it 'works' do
          expected = [
            {
              id: 1,
              label: "Main 1",
              values: [
                { y: "hello" }
              ]
            },
            {
              id: 2,
              label: "Main 2",
              values: [
              ]
            }
          ]
          expect(subject.to_a).to eql(expected)
        end
      end

    end
  end
end

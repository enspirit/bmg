require 'spec_helper'
module Bmg
  module Operator
    describe Image do

      let(:left) {
        [
          { id: 1, label: "Main 1" },
          { id: 2, label: "Main 2" }
        ]
      }

      let(:right) {
        [
          { id: 1, x: "foo", y: "hello" },
          { id: 1, x: "bar", y: "world" }
        ]
      }

      subject {
        Image.new(Type::ANY, left, right, :values, [:id], options)
      }

      context 'with option to convert to an array' do
        let(:options) { { array: true } }

        it 'works' do
          expected = [
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
          ]
          expect(subject.to_a).to eql(expected)
        end
      end

      context 'without the option' do
        let(:options) { {  } }

        it 'keeps relation as values' do
          expect(subject.to_a.all?{|t| t[:values].is_a?(Relation) }).to be(true)
        end

      end

    end
  end
end

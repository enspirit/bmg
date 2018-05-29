require 'spec_helper'
module Bmg
  module Operator
    describe NotMatching do

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
        NotMatching.new(Type::ANY, left, right, [:id])
      }

      it 'works' do
        expected = [
          {
            id: 2,
            label: "Main 2"
          }
        ]
        expect(subject.to_a).to eql(expected)
      end

    end
  end
end

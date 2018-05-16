require 'spec_helper'
module Bmg
  module Operator
    describe Group do

      let(:operand) {
        [
          { id: 1, label: "Main 1", hobby: "foo" },
          { id: 1, label: "Main 1", hobby: "bar" },
          { id: 2, label: "Main 2", hobby: "baz" }
        ]
      }

      subject {
        Group.new(Type::ANY, operand, [:hobby], :hobbies, array: true)
      }

      it 'works' do
        expected = [
          { 
            id: 1,
            label: "Main 1",
            hobbies: [
              { hobby: "foo" },
              { hobby: "bar" }
            ]
          },
          { 
            id: 2,
            label: "Main 2",
            hobbies: [
              { hobby: "baz" }
            ]
          }
        ]
        expect(subject.to_a).to eql(expected)
      end

    end
  end
end

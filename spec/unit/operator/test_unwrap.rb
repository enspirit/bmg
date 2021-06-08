require 'spec_helper'
module Bmg
  module Operator
    describe Unwrap do

      let(:operand) {
        Relation.new [
          { id: 1, :wrapped => { label: "Main 1", hobby: "foo" } },
          { id: 2, :wrapped => { label: "Main 2", hobby: "baz" } }
        ]
      }

      subject {
        Unwrap.new(Type::ANY, operand, [:wrapped])
      }

      it 'works' do
        expected = [
          { id: 1, label: "Main 1", hobby: "foo" },
          { id: 2, label: "Main 2", hobby: "baz" }
        ]
        expect(subject.to_a).to eql(expected)
      end

    end
  end
end

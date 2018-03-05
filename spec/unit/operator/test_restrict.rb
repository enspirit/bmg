require 'spec_helper'
module Bmg
  module Operator
    describe Restrict do

      let(:data) {
        [
          { a: 1,  b: 2 },
          { a: 11, b: 2 }
        ]
      }

      subject {
        Restrict.new data, Predicate.gt(:a, 10)
      }

      it 'works' do
        expect(subject.to_a).to eql([
          { a: 11, b: 2 }
        ])
      end

      it 'optimizes restrict' do
        pred = Predicate.lt(:b, 10)
        op = subject.restrict(pred)
        expect(op).to be_a(Restrict)
        expect(op.send(:predicate)).to eql(subject.send(:predicate) & pred)
        expect(op.send(:operand)).to be(data)
      end

    end
  end
end

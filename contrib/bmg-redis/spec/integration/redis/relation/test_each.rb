require 'spec_helper'

module Bmg::Redis
  describe Relation, "each" do

    subject do
      suppliers_relvar(type)
    end

    context 'when a valid type is provided' do
      let(:type) do
        suppliers_type
      end

      it 'works' do
        expect(subject).to be_a(Bmg::Relation)
      end

      it 'returns all tuples by default' do
        expect(subject.to_set).to eql(suppliers.to_set)
      end
    end

    describe 'when no key is known' do
      let(:type) do
        Bmg::Type::ANY
      end

      it 'raises' do
        expect {
          subject
        }.to raise_error(Bmg::Error)
      end
    end
  end
end

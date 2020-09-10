require 'spec_helper'
module Bmg
  describe OutputPreferences, "order_attrlist" do

    subject{
      OutputPreferences.new(options).order_attrlist(list)
    }

    context 'with no attribute ordering' do
      let(:options){{
      }}
      let(:list){
        [:firstname, :id, :lastname]
      }

      it 'returns the list itself' do
        expect(subject).to be(list)
      end
    end

    context 'with a full list' do
      let(:options){{
        attributes_ordering: [:id, :firstname, :lastname]
      }}
      let(:list){
        [:firstname, :id, :lastname]
      }

      it 'returns an ordered list' do
        expect(subject).to eql([:id, :firstname, :lastname])
      end
    end

    context 'with a partial list and extra attributes after the others' do
      let(:options){{
        attributes_ordering: [:firstname, :lastname],
        extra_attributes: :after
      }}
      let(:list){
        [:id, :lastname, :firstname]
      }

      it 'returns an ordered list' do
        expect(subject).to eql([:firstname, :lastname, :id])
      end
    end

    context 'with a partial list and extra attributes before the others' do
      let(:options){{
        attributes_ordering: [:firstname, :lastname],
        extra_attributes: :before
      }}
      let(:list){
        [:id, :lastname, :firstname]
      }

      it 'returns an ordered list' do
        expect(subject).to eql([:id, :firstname, :lastname])
      end
    end
  end
end


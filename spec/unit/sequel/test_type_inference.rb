require 'spec_helper'
module Bmg
  module Sequel
    describe TypeInference do

      let(:inference) {
        TypeInference.new(sequel_db)
      }

      describe 'attrlist' do

        it 'supports inference attrlist on a table name' do
          expected = [:sid, :name, :status, :city]
          expect(inference.attrlist(:suppliers)).to eql(expected)
        end

      end

      describe 'keys' do

        it 'supports key inference on a table name' do
          expected = [[:sid], [:name]]
          expect(inference.keys(:suppliers)).to eql(expected)
        end

      end

    end
  end
end

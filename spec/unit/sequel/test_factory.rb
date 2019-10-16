require 'spec_helper'
module Bmg
  describe Sequel, "Relation factory" do
    describe 'sequel_params' do

      let(:a_type) {
        Type.new.with_attrlist([:sid, :name, :status, :city])
      }

      let(:dataset) {
        sequel_db[:suppliers]
      }

      it 'supports a dataset if a type is provided' do
        source, db, type = Sequel.sequel_params(dataset, a_type)
        expect(source).to be(dataset)
        expect(db).to be(sequel_db)
        expect(type).to be(a_type)
      end

      it 'supports a table name and Sequel Database' do
        source, db, type = Sequel.sequel_params(:suppliers, sequel_db)
        expect(source).to eql(:suppliers)
        expect(db).to be(sequel_db)
        expect(type).to be_a(Type)
        expect(type.to_attrlist).to eql([:sid, :name, :status, :city])
      end

      it 'supports a qualified table name and Sequel Database' do
        q_table = ::Sequel.qualify(:main,:suppliers)
        source, db, type = Sequel.sequel_params(q_table, sequel_db)
        expect(source).to eql(q_table)
        expect(db).to be(sequel_db)
        expect(type).to be_a(Type)
        expect(type.to_attrlist).to eql([:sid, :name, :status, :city])
      end

      it 'supports a table name, a Sequel Database, and a type' do
        source, db, type = Sequel.sequel_params(:suppliers, sequel_db, a_type)
        expect(source).to eql(:suppliers)
        expect(db).to be(sequel_db)
        expect(type).to be(a_type)
      end

      it 'raises when no sequel database can be found' do
        expect{
          Sequel.sequel_params(:suppliers)
        }.to raise_error(/A Sequel::Database object is required/)
      end

    end
  end
end


require 'spec_helper'
module Bmg
  module Sequel
    describe Relation, "insert" do

      around do |bl|
        sequel_db.transaction do
          bl.call
          raise ::Sequel::Rollback
        end
      end

      let(:relation) {
        Bmg.sequel(:suppliers, sequel_db)
      }

      context "on a base relation" do

        it 'works as expected' do
          relation.insert({:sid => "S6", :name => "Ron", :status => 10, :city => "New York"})
          expect(relation.count).to eql(6)
        end

      end

    end
  end
end

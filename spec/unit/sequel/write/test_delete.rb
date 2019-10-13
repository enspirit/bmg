require 'spec_helper'
module Bmg
  module Sequel
    describe Relation, "delete" do

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
          relation.delete
          expect(relation.count).to eql(0)
        end

      end

    end
  end
end

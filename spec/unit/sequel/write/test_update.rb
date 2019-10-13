require 'spec_helper'
module Bmg
  module Sequel
    describe Relation, "update" do

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
          relation.update(:city => "New York")
          expect(relation.project([:city]).count).to eql(1)
        end

      end

    end
  end
end

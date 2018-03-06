require 'spec_helper'
module Bmg
  module Sequel
    describe Relation do

      let(:relation) {
        Bmg.sequel(sequel_db[:suppliers])
      }

      it 'works' do
        expect(relation.to_a.size).to eql(5)
      end

      it 'optimizes restrictions' do
        optimized = relation.restrict(sid: "S1")
        expect(optimized).to be_a(Sequel::Relation)
        expect(optimized.send(:dataset).sql).to eql(<<-SQL.gsub(/\s+/, " ").strip)
          SELECT * FROM `suppliers` WHERE (`sid` = 'S1')
        SQL
      end

      it 'does not fail when a native predicate is used' do
        optimized = relation.restrict(->(t){ false })
        expect(optimized).to be_a(Operator::Restrict)
        expect(optimized.to_a).to be_empty
      end

    end
  end
end

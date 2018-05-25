require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Merge, "on_select_exp" do

        subject{ Merge.new(:intersect, right, builder(1)).on_select_exp(expr) }

        context 'when right a simple select_exp' do
          let(:expr){
            # SELECT * FROM t1
            select_all
          }

          let(:right){
            # SELECT * FROM t2
            select_all_t2
          }

          let(:expected){
            # SELECT * FROM t1 INTERSECT SELECT * FROM t2
            intersect
          }

          it{ should eq(expected) }
        end

        context 'when right an intersect' do
          let(:expr){
            # SELECT * FROM t1
            select_all
          }

          let(:right){
            # SELECT * FROM t1 INTERSECT SELECT * FROM t2
            intersect
          }

          let(:expected){
            # SELECT * FROM t1 INTERSECT SELECT * FROM t1 INTERSECT SELECT * FROM t2
            intersect(expr, right)
          }

          it{ should eq(expected) }
        end

        context 'when right is a with_exp' do
          let(:expr){
            # SELECT * FROM t1
            select_all
          }

          let(:right){
            # WITH t2 AS ...
            # SELECT * FROM t2
            with_exp({t2: select_all_t2}, select_all_t2)
          }

          let(:expected){
            # WITH t2 AS ...
            # SELECT * FROM t1 INTERSECT SELECT * FROM t2
            with_exp(
              {t2: select_all_t2},
              intersect(select_all, select_all_t2))
          }

          it{ should eq(expected) }
        end

      end
    end
  end
end

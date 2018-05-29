require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Merge, "on_with_exp" do

        subject{ Merge.new(:intersect, false, right, builder(1)).on_with_exp(expr) }

        context 'when right is a simple exp' do
          let(:expr){
            # with t1 AS ...
            #      SELECT * FROM t1
            with_exp({t1: select_all}, select_all)
          }

          let(:right){
            # SELECT * FROM t2
            select_all_t2
          }

          let(:expected){
            # WITH t1 AS ...
            # SELECT * FROM t1 INTERSECT SELECT * FROM t2
            with_exp({t1: select_all}, intersect)
          }

          it{ should eq(expected) }
        end

        context 'when right is a with_exp' do
          let(:expr){
            # WITH t1 AS ...
            # SELECT * FROM t1
            with_exp({t1: select_all}, select_all)
          }

          let(:right){
            # WITH t2 AS ...
            # SELECT * FROM t2
            with_exp({t2: select_all_t2}, select_all_t2)
          }

          let(:expected){
            # WITH t1 AS ...
            #      t2 AS ...
            # SELECT * FROM t1 INTERSECT SELECT * FROM t2
            with_exp({t1: select_all, t2: select_all_t2}, intersect)
          }

          it{ should eq(expected) }
        end

      end
    end
  end
end

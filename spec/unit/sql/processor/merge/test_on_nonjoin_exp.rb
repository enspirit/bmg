require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Merge, "on_nonjoin_exp" do

        subject{ Merge.new(:intersect, false, right, builder(1)).on_nonjoin_exp(expr) }

        context 'when left is an intersect already' do
          let(:expr){
            # SELECT * FROM t1 INTERSECT SELECT * FROM t2
            intersect
          }

          let(:right){
            # SELECT * FROM t1
            select_all
          }

          let(:expected){
            # SELECT * FROM t1 INTERSECT SELECT * FROM t1 INTERSECT SELECT * FROM t2
            nary_intersect(expr, right)
          }

          it{ should eq(expected) }
        end

      end
    end
  end
end

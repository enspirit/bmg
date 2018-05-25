require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe OrderBy, "on_select_exp" do

        subject{ OrderBy.new(ordering, builder).on_select_exp(expr) }

        context 'when not already ordered' do
          let(:expr){
            select_all
          }

          let(:expected){
            select_all.push(order_by_clause)
          }

          it{ should eq(expected) }
        end

      end
    end
  end
end

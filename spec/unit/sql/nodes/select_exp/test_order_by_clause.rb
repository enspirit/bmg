require 'sql_helper'
module Bmg
  module Sql
    describe SelectExp, "order_by_clause" do

      subject{ expr.order_by_clause }

      context 'when an order by clause' do
        let(:expr){ select_all.push(order_by_clause) }

        it{ should eq(order_by_clause) }
      end

      context 'without such clause' do
        let(:expr){ select_all }

        it{ should be_nil }
      end

    end
  end
end

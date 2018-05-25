require 'sql_helper'
module Bmg
  module Sql
    describe OrderByTerm, "direction" do

      subject{ expr.direction }

      context 'when qualified' do
        let(:expr){ order_by_term(qualified_name('t1', 'a'), "asc") }

        it{ should eq('asc') }
      end

      context 'when not qualified' do
        let(:expr){ order_by_term(column_name_a, "asc") }

        it{ should eq('asc') }
      end

    end
  end
end

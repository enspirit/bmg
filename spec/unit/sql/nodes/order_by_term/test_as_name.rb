require 'sql_helper'
module Bmg
  module Sql
    describe OrderByTerm, "as_name" do

      subject{ expr.as_name }

      context 'when qualified' do
        let(:expr){ order_by_term(qualified_name('t1', 'a'), "asc") }

        it{ should eq('a') }
      end

      context 'when not qualified' do
        let(:expr){ order_by_term(column_name_a, "asc") }

        it{ should eq('a') }
      end

    end
  end
end

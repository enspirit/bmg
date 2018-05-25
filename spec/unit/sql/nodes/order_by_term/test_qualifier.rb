require 'sql_helper'
module Bmg
  module Sql
    describe OrderByTerm, "qualifier" do

      subject{ expr.qualifier }

      context 'when qualified' do
        let(:expr){ order_by_term(qualified_name('t1', 'a'), "asc") }

        it{ should eq('t1') }
      end

      context 'when not qualified' do
        let(:expr){ order_by_term(column_name_a, "asc") }

        it{ should be_nil }
      end

    end
  end
end

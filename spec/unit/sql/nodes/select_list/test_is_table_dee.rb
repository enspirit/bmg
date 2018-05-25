require 'sql_helper'
module Bmg
  module Sql
    describe SelectList, "is_table_dee" do

      subject{ expr.is_table_dee? }

      context 'on a normal select list' do
        let(:expr){ select_list }

        it{ should be(false) }
      end

      context 'on a is_table_dee select list' do
        let(:expr){ Builder::IS_TABLE_DEE.dup }

        it{ should be(true) }
      end

    end
  end
end

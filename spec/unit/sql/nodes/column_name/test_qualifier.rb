require 'sql_helper'
module Bmg
  module Sql
    describe ColumnName, "qualifier" do

      subject{ expr.qualifier }

      let(:expr){ column_name_a }

      it{ should be_nil }

    end
  end
end

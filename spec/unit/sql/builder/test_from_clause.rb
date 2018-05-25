require 'sql_helper'
module Bmg
  module Sql
    describe Builder, "from_clause" do

      context 'with a table name' do
        subject{ builder.from_clause(:table, :t1) }

        let(:expected){
          [:from_clause,
            [:table_as, [:table_name, :table], [:range_var_name, :t1]] ]
        }

        it{ should eq(expected) }
      end

      context 'with a sub query' do
        subject{ builder.from_clause(builder.select_star_from(:table), :t2) }

        let(:expected){
          [:from_clause,
           [:subquery_as,
            [:select_exp,
             [:set_quantifier, "all"],
             [:select_star, [:range_var_name, "t1"]],
             [:from_clause,
              [:table_as, [:table_name, :table], [:range_var_name, "t1"]]]],
            [:range_var_name, :t2]]]
        }

        it{ should eq(expected) }
      end

      context 'with a native object' do
        let(:native){ Object.new }
        subject{ builder.from_clause(native, :t1) }

        let(:expected){
          [:from_clause,
           [:native_table_as, native, [:range_var_name, :t1]]]
        }

        it{ should eq(expected) }
      end

    end
  end
end

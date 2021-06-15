require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Summarize, "on_select_exp" do

        subject{
          Summarize.new([:a], {
            :b => Bmg::Summarizer.sum(:b),
            :c => Bmg::Summarizer.min(:a)
          }, Builder.new(1)).on_select_exp(expr)
        }

        context 'when' do
          let(:expr){
            select_all
          }

          let(:expected){
            [:select_exp, [:set_quantifier, "all"],
              [:select_list,
                [:select_item, [:qualified_name, [:range_var_name, "t1"], [:column_name, "a"]], [:column_name, "a"]],
                [:select_item, [:summarizer, :sum, [:qualified_name, [:range_var_name, "t1"], [:column_name, "b"]]], [:column_name, "b"]],
                [:select_item, [:summarizer, :min, [:qualified_name, [:range_var_name, "t1"], [:column_name, "a"]]], [:column_name, "c"]]],
              [:from_clause,
                [:table_as, [:table_name, "t1"], [:range_var_name, "t1"]]],
              [:group_by_clause,
                [:qualified_name, [:range_var_name, "t1"], [:column_name, "a"]]]]
          }

          it{
            should eq(expected)
          }
        end

      end
    end
  end
end

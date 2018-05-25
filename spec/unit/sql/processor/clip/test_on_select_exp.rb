require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Clip, "on_select_exp" do

        subject{
          Clip.new([:a], false, :is_table_dee, Builder.new).on_select_exp(expr)
        }

        context 'normal_case' do
          let(:expr){ select_all }

          it{ should eq(select_all_a) }
        end

        context 'distinct_case' do
          let(:expr){ select_distinct }

          it{ should eq(select_distinct_a) }
        end

        context 'when leading to an empty select_list' do
          let(:expr){ select_all_b }

          context 'the default behavior' do
            it{ should eq(select_is_table_dee(select_all_star)) }
          end
        end

      end
    end
  end
end

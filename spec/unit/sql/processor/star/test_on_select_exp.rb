require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Star, "on_select_list" do

        subject{ Star.new(Builder.new).on_select_exp(expr) }

        context 'on select_all' do
          let(:expr){ select_all }

          it{ should eq(select_all_star) }
        end

        context 'on select_distinct' do
          let(:expr){ select_distinct }

          it{ should eq(select_distinct_star) }
        end

      end
    end
  end
end

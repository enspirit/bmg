require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Reorder, "on_select_list" do

        subject{ Reorder.new([:b, :a], Builder.new).on_select_list(expr) }

        let(:expr){
          select_list_ab
        }

        let(:expected){
          select_list_ba
        }

        it{ should eq(expected) }

      end
    end
  end
end

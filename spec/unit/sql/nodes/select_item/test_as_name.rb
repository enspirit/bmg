require 'sql_helper'
module Bmg
  module Sql
    describe SelectItem, "as_name" do

      subject{ expr.as_name }

      context 'on a select item with no real renaming' do
        let(:expr){ select_item("a", "a") }

        it{ should eq("a") }
      end

      context 'on a select item with with real renaming' do
        let(:expr){ select_item("a", "x") }

        it{ should eq("x") }
      end

    end
  end
end

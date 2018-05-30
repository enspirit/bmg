require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Constants, "on_select_list" do

        subject{
          Constants.new({foo: "bar", baz: 2, hello: nil}, Builder.new).on_select_list(expr)
        }

        context 'when included' do
          let(:expr){
            select_list_ab
          }

          let(:expected){
            select_list_ab + [
              [:select_item, [:literal, "bar"], [:column_name, "foo"]],
              [:select_item, [:literal, 2],     [:column_name, "baz"]],
              [:select_item, [:literal, nil],   [:column_name, "hello"]]
            ]
          }

          it{ should eq(expected) }
        end

      end
    end
  end
end

require 'sql_helper'
module Bmg
  module Sql
    describe Processor, "on_select_exp" do

      let(:clazz){
        Class.new(Processor){
          def on_select_list(sexpr)
            [:foo, :bar, sexpr]
          end
        }
      }

      subject{ clazz.new(Builder.new).on_select_exp(expr) }

      let(:expr){
        Grammar.sexpr [:select_exp, distinct, select_list_ab, [:baz]]
      }

      let(:expected){
        [:select_exp, distinct, [:foo, :bar, select_list_ab], [:baz]]
      }

      it{ should eq(expected) }

    end
  end
end

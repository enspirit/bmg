require 'sql_helper'
module Bmg
  module Sql
    describe Processor, "on_set_operator" do

      let(:clazz){
        Class.new(Processor){
          def on_select_exp(sexpr)
            [:foo, :bar, sexpr]
          end
        }
      }

      subject{ clazz.new(Builder.new).on_set_operator(expr) }

      let(:expr){
        [:union, all, select_all_a, select_all_b]
      }

      let(:expected){
        [:union, all, [:foo, :bar, select_all_a], [:foo, :bar, select_all_b]]
      }

      it{ should eq(expected) }

    end
  end
end

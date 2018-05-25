require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Distinct, "on_set_quantified" do

        subject{ Distinct.new(Builder.new).on_set_quantified(expr) }

        let(:expected){
          [:x, distinct]
        }

        context 'when already distinct' do
          let(:expr){
            Grammar.sexpr [:x, distinct]
          }

          it{ should eq(expected) }
        end

        context 'when not distinct' do
          let(:expr){
            Grammar.sexpr [:x, all]
          }

          it{ should eq(expected) }
        end
      end
    end
  end
end

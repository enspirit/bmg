require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Bind, "on_select_exp" do

        subject{
          Bind.new(binding, Builder.new(1)).apply(expr)
        }

        let(:placeholder){
          Predicate.placeholder
        }

        let(:binding) {
          { placeholder => 12 }
        }

        context 'when not already ordered' do
          let(:expr){
            select_a << Grammar.sexpr([ :where_clause, Predicate.eq(:x, placeholder).sexpr ])
          }

          let(:expected){
            select_a << Grammar.sexpr([ :where_clause, Predicate.eq(:x, 12).sexpr ])
          }

          it{
            should eq(expected)
          }
        end

      end
    end
  end
end

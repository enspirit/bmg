require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Requalify, "on_where_clause" do

        subject{ Requalify.new(Builder.new(1)).apply(expr) }

        context 'with a predicate to requalify' do
          let(:expr){
            sexpr [:where_clause, Predicate.eq(:x, 1).qualify(:t1).sexpr ]
          }

          let(:expected){
            sexpr [:where_clause, Predicate.eq(:x, 1).qualify(:t2).sexpr ]
          }

          it{ should eq(expected) }
        end

      end
    end
  end
end

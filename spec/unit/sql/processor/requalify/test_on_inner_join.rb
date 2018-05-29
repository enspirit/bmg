require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Requalify, "on_inner_join" do

        subject{ Requalify.new(Builder.new(2)).apply(expr) }

        context 'with a predicate to requalify' do
          let(:expr){
            sexpr [ :inner_join,
              [:table_as, [:table_name, :supplies], [:range_var_name, "t1"]],
              [:table_as, [:table_name, :parts],    [:range_var_name, "t2"]],
              Predicate::Grammar.sexpr([:eq,
                [:qualified_identifier, :t1, :pid],
                [:qualified_identifier, :t2, :pid]
              ])
            ]
          }

          let(:expected){
            sexpr [ :inner_join,
              [:table_as, [:table_name, :supplies], [:range_var_name, "t3"]],
              [:table_as, [:table_name, :parts],    [:range_var_name, "t4"]],
              Predicate::Grammar.sexpr([:eq,
                [:qualified_identifier, :t3, :pid],
                [:qualified_identifier, :t4, :pid]
              ])
            ]
          }

          it{ should eq(expected) }
        end

      end
    end
  end
end

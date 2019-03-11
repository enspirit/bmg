require 'sql_helper'
module Bmg
  module Sql
    describe Builder, "group_by_clause" do

      let(:attrs){ [:name, :city] }

      context 'without desaliaser' do
        subject{ builder.group_by_clause(attrs) }

        let(:expected){
          [:group_by_clause,
            [ :column_name, 'name' ],
            [ :column_name, 'city' ]]
        }

        it{ should eq(expected) }
      end

      context 'with a desaliaser' do
        let(:desaliaser){
          ->(a){
            if a == "name"
              [:qualified_name, [:range_var_name, "t1"], [:column_name, a]]
            else
              [:qualified_name, [:range_var_name, "t2"], [:column_name, a]]
            end
          }
        }

        subject{ builder.group_by_clause(attrs, &desaliaser) }

        let(:expected){
          [:group_by_clause,
            [:qualified_name, [:range_var_name, "t1"], [:column_name, 'name']],
            [:qualified_name, [:range_var_name, "t2"], [:column_name, 'city']]]
        }

        it{ should eq(expected) }
      end

    end
  end
end

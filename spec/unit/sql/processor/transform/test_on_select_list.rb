require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Transform, "on_select_list" do

        subject{
          Transform.new({
            :a => Date
          }, {}, Builder.new).on_select_list(expr)
        }

        let(:expr){
          sexpr [:select_list,
            [:select_item,
              [:qualified_name,
                [:range_var_name, "t1"],
                [:column_name, "a"]
              ],
              [:column_name, "a"]
            ]
          ]
        }

        let(:expected){
          sexpr [:select_list,
            [:select_item,
              [:func_call,
                :cast,
                [:qualified_name,
                  [:range_var_name, "t1"],
                  [:column_name, "a"]
                ],
                [ :literal, Date ]
              ],
              [:column_name, "a"]
            ]
          ]
        }

        it{ should eq(expected) }

      end
    end
  end
end

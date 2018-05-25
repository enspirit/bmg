require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe FromSelf, "on_with_exp" do

        subject{ FromSelf.new(builder(1)).on_with_exp(expr) }

        let(:expr){
          with_exp({t1: select_all}, select_all_t2)
        }

        let(:expected){
          with_exp({t1: select_all, t2: select_all_t2}, select_all_t2)
        }

        it{ should eq(expected) }

      end
    end
  end
end

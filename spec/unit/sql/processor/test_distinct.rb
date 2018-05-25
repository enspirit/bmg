require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Distinct do

        subject{ Distinct.new(Builder.new).call(expr) }

        context 'on a select_exp' do
          let(:expr){ select_all }

          it{ should eq(select_distinct) }
        end

        context 'on a with_exp' do
          let(:expr){ with_exp(nil, select_all) }

          it{ should eq(with_exp(nil, select_distinct)) }
        end

      end
    end
  end
end

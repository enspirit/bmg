require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Rename do

        subject{ Rename.new({:a => :b}, Builder.new).call(expr) }

        context 'on a select_exp' do
          let(:expr){ select_all_a }

          it{ should eq(select_all_a_as_b) }
        end

        context 'on a with_exp' do
          let(:expr){ with_exp(nil, select_all_a) }

          it{ should eq(with_exp(nil, select_all_a_as_b)) }
        end

      end
    end
  end
end

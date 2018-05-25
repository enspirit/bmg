require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Clip, "on_select_list" do

        context 'allbut = false' do

          subject{
            Clip.new([:a], false, :is_table_dee, Builder.new).on_select_list(expr)
          }

          context 'when included' do
            let(:expr){ select_list_ab }

            it{ should eq(select_list_a) }
          end

          context 'when unique' do
            let(:expr){ select_list_a }

            it{ should eq(select_list_a) }
          end

        end

        context 'allbut = true' do

          subject{
            Clip.new([:a], true, :is_table_dee, Builder.new).on_select_list(expr)
          }

          context 'when included' do
            let(:expr){ select_list_ab }

            it{ should eq(select_list_b) }
          end

        end

      end
    end
  end
end

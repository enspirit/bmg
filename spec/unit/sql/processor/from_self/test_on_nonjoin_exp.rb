require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe FromSelf, "on_nonjoin_exp" do

        subject{ FromSelf.new(builder).on_nonjoin_exp(expr) }

        context 'on select_exp' do
          let(:expr){
            select_all
          }

          let(:expected){
            with_exp(t1: select_all)
          }

          it{ should eq(expected) }
        end

        context 'on union' do
          let(:expr){
            union
          }

          let(:expected){
            with_exp(t1: union)
          }

          it{ should eq(expected) }
        end

        context 'on intersect' do
          let(:expr){
            intersect
          }

          let(:expected){
            with_exp(t1: intersect)
          }

          it{ should eq(expected) }
        end

        context 'on except' do
          let(:expr){
            except
          }

          let(:expected){
            with_exp(t1: except)
          }

          it{ should eq(expected) }
        end

      end
    end
  end
end

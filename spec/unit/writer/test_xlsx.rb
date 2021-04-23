require 'spec_helper'
require 'date'
require 'bmg/writer/xlsx'
module Bmg
  module Writer
    describe Xlsx do

      subject{ relation.to_xlsx(*args) }

      let(:date) {
        Date.parse('2021/04/23')
      }

      let(:relation) {
        Relation.new [
          { id: 1, name: "Bernard", nonnum: "1", when: date },
          { id: 2, name: "Yoann",   nonnum: "2", when: date }
        ]
      }

      context 'with default options and a path' do
        let(:path){ Path.dir/"result.xlsx" }
        let(:args){ [ path ] }

        it 'works' do
          expect(subject).to eql(args.first)
          reloaded = Bmg.excel(path).to_set
          expect(reloaded).to eql(relation.map{|t|
            t.merge(:when => t[:when].to_s)
          }.to_set)
        end
      end

    end
  end
end

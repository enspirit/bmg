require 'spec_helper'
module Bmg
  module Writer
    describe Csv do

      subject{ relation.to_csv(*args) }

      let(:relation) {
        Relation.new [
          {id: "1", name: "Bernard Lambeau"},
          {id: "2", name: "Yoann;Guyot"}
        ]
      }

      context 'with default options and no output' do
        let(:args){ [] }

        it 'works' do
          expected = <<~CSV
            1,Bernard Lambeau
            2,Yoann;Guyot
          CSV
          expect(subject).to eql(expected)
        end
      end

      context 'with an output only' do
        let(:args){ [ StringIO.new ] }

        it 'works' do
          expect(subject).to eql(args[0])
          expected = <<~CSV
            1,Bernard Lambeau
            2,Yoann;Guyot
          CSV
          expect(subject.string).to eql(expected)
        end
      end

      context 'with an output, and options' do
        let(:args){ [ {}, StringIO.new ] }

        it 'works' do
          expect(subject).to eql(args[1])
          expected = <<~CSV
            1,Bernard Lambeau
            2,Yoann;Guyot
          CSV
          expect(subject.string).to eql(expected)
        end
      end

      context 'specifying inline CSV options' do
        let(:args){ [ {col_sep: ";"} ] }

        it 'works' do
          expected = <<~CSV
            1;Bernard Lambeau
            2;"Yoann;Guyot"
          CSV
          expect(subject).to eql(expected)
        end
      end

      context 'specifying that CSV headers must be included' do
        let(:args){ [ {write_headers: true} ] }

        it 'works' do
          expected = <<~CSV
            id,name
            1,Bernard Lambeau
            2,Yoann;Guyot
          CSV
          expect(subject).to eql(expected)
        end
      end

      context 'when specifying a header ordering preference' do
        let(:args){ [ {}, { attributes_ordering: [:name, :id] } ] }

        it 'works' do
          expected = <<~CSV
            Bernard Lambeau,1
            Yoann;Guyot,2
          CSV
          expect(subject).to eql(expected)
        end
      end

      context 'when specifying a tuple ordering preference' do
        let(:args){ [ {}, { tuple_ordering: [[:name, :desc]] } ] }

        it 'works' do
          expected = <<~CSV
            2,Yoann;Guyot
            1,Bernard Lambeau
          CSV
          expect(subject).to eql(expected)
        end
      end

      context 'when specifying some grouping attributes' do
        let(:args){
          [ {}, { grouping_attributes: [:date, :reference] } ]
        }

        let(:relation) {
          Relation.new [
            {date: "2024-01-18", reference: "AAA", id: "1", name: "Bernard Lambeau"},
            {date: "2024-01-18", reference: "AAA", id: "2", name: "Yoann Guyot"},
            {date: "2024-01-18", reference: "BBB", id: "3", name: "Louis Lambeau"},
            {date: "2024-01-19", reference: "AAA", id: "4", name: "David Parloir"},
          ]
        }

        it 'works' do
          expected = <<~CSV
            2024-01-18,AAA,1,Bernard Lambeau
            ,,2,Yoann Guyot
            ,BBB,3,Louis Lambeau
            2024-01-19,AAA,4,David Parloir
          CSV
          expect(subject).to eql(expected)
        end
      end

    end
  end
end

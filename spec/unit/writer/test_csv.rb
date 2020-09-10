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

      context 'when specifying an ordering preference' do
        let(:args){ [ {}, { attributes_ordering: [:name, :id] } ] }

        it 'works' do
          expected = <<~CSV
            Bernard Lambeau,1
            Yoann;Guyot,2
          CSV
          expect(subject).to eql(expected)
        end
      end

    end
  end
end

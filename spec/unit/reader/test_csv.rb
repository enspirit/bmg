require 'spec_helper'
module Bmg
  module Reader
    describe Csv do

      subject {
        Csv.new(Type::ANY, input)
      }

      context 'when a .csv file' do
        let(:input){ Path.dir/("example.csv") }

        it_behaves_like "a Relation-compatible"

        it 'works' do
          expect(subject.to_a).to eql([
            {id: "1", name: "Bernard Lambeau"},
            {id: "2", name: "Yoann;Guyot"}
          ])
        end

        it 'knows its attributes' do
          expect(subject.type.attrlist).to eql([:id, :name])
        end
      end

      context 'when a IO object' do
        let(:input){ Path.dir/("example.csv") }

        it 'works' do
          input.open('r') do |io|
            csv = Csv.new(Type::ANY, io, col_sep: ";", quote_char: '"')
            expect(csv.to_a).to eql([
              {id: "1", name: "Bernard Lambeau"},
              {id: "2", name: "Yoann;Guyot"}
            ])
          end
        end

        it 'knows its attributes' do
          expect(subject.type.attrlist).to eql([:id, :name])
        end
      end

      context 'when a StringIO object' do
        let(:input){ StringIO.new((Path.dir/"example.csv").read) }

        it 'works' do
          expect(subject.to_a).to eql([
            {id: "1", name: "Bernard Lambeau"},
            {id: "2", name: "Yoann;Guyot"}
          ])
        end

        it 'knows its attributes' do
          expect(subject.type.attrlist).to eql([:id, :name])
        end
      end

      context 'when a .csv file with normal quotes' do
        let(:input){ Path.dir/("infer-quotes.csv") }

        it_behaves_like "a Relation-compatible"

        it 'works' do
          expect(subject.to_a).to eql([
            {id: "1", name: "Bernard's Lambeau"},
            {id: "2", name: "Yoann's Guyot"}
          ])
        end

        it 'knows its attributes' do
          expect(subject.type.attrlist).to eql([:id, :name])
        end
      end

      context 'when a .csv file with all quotes' do
        let(:input){ Path.dir/("infer-quotes-2.csv") }

        it_behaves_like "a Relation-compatible"

        it 'works' do
          expect(subject.to_a).to eql([
            {id: "1", name: "Bernard's Lambeau"},
            {id: "2", name: "Yoann's Guyot"},
            {id: "3", name: "Louis's Lambeau"}
          ])
        end

        it 'knows its attributes' do
          expect(subject.type.attrlist).to eql([:id, :name])
        end
      end

    end
  end
end

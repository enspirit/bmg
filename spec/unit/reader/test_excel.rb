require 'spec_helper'
module Bmg
  module Reader
    describe Excel do

      subject {
        Excel.new(Type::ANY, input, options)
      }

      context "with a .xlsx file" do
        let(:input) {
          Path.dir/("example.xlsx")
        }
        let(:options) {
          { skip: 1 }
        }

        it_behaves_like "a Relation-compatible"

        it 'works' do
          expect(subject.to_a).to eql([
            {row_num: 1, id: 1, name: "Bernard Lambeau"},
            {row_num: 2, id: 2, name: "Yoann Guyot"}
          ])
        end
      end

      context "when specifying the extension" do
        let(:input) {
          Path.dir/("example.excel")
        }
        let(:options) {
          { skip: 1, extension: "xlsx" }
        }

        it "allows specifying the extension through Roo's option" do
          expect(subject.to_a).to eql([
            {row_num: 1, id: 1, name: "Bernard Lambeau"},
            {row_num: 2, id: 2, name: "Yoann Guyot"}
          ])
        end
      end

      context "when skipping row num" do
        let(:input) {
          Path.dir/("example.xlsx")
        }
        let(:options) {
          { skip: 1, row_num: false }
        }

        it "allows skipping row nums" do
          expect(subject.to_a).to eql([
            {id: 1, name: "Bernard Lambeau"},
            {id: 2, name: "Yoann Guyot"}
          ])
        end
      end

      context "when skipping row num" do
        let(:input) {
          Path.dir/("example.xlsx")
        }
        let(:options) {
          { skip: 1, row_num: :anid }
        }

        it "allows renaming row nums" do
          expect(subject.to_a).to eql([
            {anid: 1, id: 1, name: "Bernard Lambeau"},
            {anid: 2, id: 2, name: "Yoann Guyot"}
          ])
        end
      end

    end
  end
end

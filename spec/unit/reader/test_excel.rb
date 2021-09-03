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

      context "with specifying the sheet to use" do
        let(:input) {
          Path.dir/("example.xlsx")
        }
        let(:options) {
          { skip: 1, sheet: 1 }
        }

        it_behaves_like "a Relation-compatible"

        it "works" do
          expect(subject.to_a).to eql([
            { row_num: 1, id: 1, name: "Louis Lambeau" },
            { row_num: 2, id: 2, name: "Marie Deserable" },
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

      context "On a noisy file" do
        let(:input) {
          Path.dir/("noisy.xlsx")
        }
        let(:options) {
          { row_num: false }
        }

        it "strips spaces in attribute names" do
          expect(subject.to_a).to eql([
            {:Assignee => "Bernard",
              :"Due date" => Date.parse("2021-04-30"),
              :Priority => "High",
              :Progress => "Started",
              :What => "Do whatever is necessary to import excel easily"},
            {:Assignee => "Victor",
              :"Due date" => nil,
              :Priority => "High  ",
              :Progress => "Done",
              :What => "Make Klaro much more friendly"},
            {:Assignee => "David",
              :"Due date" => Date.parse("2021-10-12"),
              :Priority => "Medium",
              :Progress => "Ongoing",
              :What => "Fix all the bugs"},
            {:Assignee => "Alice",
              :"Due date" => "xx",
              :Priority => "Low",
              :Progress => "Started  ",
              :What => "Write a fresh new CSS stylesheet"}])
        end
      end

    end
  end
end

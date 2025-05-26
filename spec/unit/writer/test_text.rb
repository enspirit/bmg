require 'spec_helper'
module Bmg
  module Writer
    describe Text do

      subject do
        Text.new.render(input)
      end

      describe "on a Relation" do
        let(:input){
          Relation.new([
            { id: 1 },
            { id: 2 },
          ])
        }
        let(:expected){
          "+----+\n"\
          "| id |\n"\
          "+----+\n"\
          "|  1 |\n"\
          "|  2 |\n"\
          "+----+\n"
        }

        it 'outputs as expected' do
          expect(subject).to eql(expected)
        end
      end

      describe "on a Hash" do
        let(:input){
          { id: 1 }
        }
        let(:expected){
          "+----+\n"\
          "| id |\n"\
          "+----+\n"\
          "|  1 |\n"\
          "+----+\n"
        }

        it 'outputs as expected' do
          expect(subject).to eql(expected)
        end
      end

      describe 'its exposition on Relation' do
        subject do
          relation.to_text
        end

        let(:relation) {
          Relation.new [
            {id: "1", name: "Bernard Lambeau"},
            {id: "2", name: "Yoann;Guyot"}
          ]
        }

        let(:expected){
          "+----+-----------------+\n"\
          "| id | name            |\n"\
          "+----+-----------------+\n"\
          "| 1  | Bernard Lambeau |\n"\
          "| 2  | Yoann;Guyot     |\n"\
          "+----+-----------------+\n"
        }

        it 'works as expected' do
          expect(subject).to eql(expected)
        end
      end

    end
  end
end

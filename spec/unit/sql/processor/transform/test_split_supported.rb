require 'sql_helper'
module Bmg
  module Sql
    class Processor
      describe Transform, "split_supported" do

        subject{
          Transform.split_supported(t, &recognizer)
        }

        let(:recognizer) {
          ->(x){
            x == String || x == :to_s || x == :to_i
          }
        }

        context "with a supported Class" do
          let(:t){
            String
          }

          it 'keeps it' do
            expect(subject).to eql([t, nil])
          end
        end

        context "with an non supported Class" do
          let(:t){
            Date
          }

          it 'rejects it' do
            expect(subject).to eql([nil, t])
          end
        end

        context "with a fully supported Hash" do
          let(:t){
            { x: String, y: :to_s }
          }

          it 'keeps it' do
            expect(subject).to eql([t, nil])
          end
        end

        context "with an non supported Array" do
          let(:t){
            [Date, :to_s]
          }

          it 'rejects it' do
            expect(subject).to eql([nil, t])
          end
        end

        context "with a fully supported Array" do
          let(:t){
            [String, :to_i]
          }

          it 'keeps it' do
            expect(subject).to eql([t, nil])
          end
        end

        context "with a mixed Array with some supported first" do
          let(:t){
            [String, :to_i, Date, :to_s]
          }

          it 'splits it' do
            expect(subject).to eql([[String, :to_i], [Date, :to_s]])
          end
        end

        context "with a singleton Array with a supported" do
          let(:t){
            [String]
          }

          it 'splits it' do
            expect(subject).to eql([String, nil])
          end
        end

        context "with a fully non supported Hash" do
          let(:t){
            { x: /a/, y: /b/ }
          }

          it 'keeps it' do
            expect(subject).to eql([nil, t])
          end
        end

        context "with mixed Hash" do
          let(:t){
            { x: /a/, y: :to_s, z: [:to_s, Date] }
          }

          it 'keeps it' do
            expect(subject).to eql([{y: :to_s, z: :to_s}, {x: /a/, z: Date}])
          end
        end

      end
    end
  end
end

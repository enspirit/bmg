require 'spec_helper'

module Bmg
  class Database
    describe "DataFolder" do

      subject {
        Database.data_folder(Path.dir.parent.parent/'suppliers-and-parts')
      }

      it 'is served by Database.data_folder' do
        expect(subject).to be_a(DataFolder)
      end

      it 'serves the json relations as expected' do
        expect(subject.suppliers).to be_a(Relation)
        expect(subject.suppliers.count).to eql(5)
      end

      it 'serves the csv relations as expected' do
        expect(subject.cities).to be_a(Relation)
        expect(subject.cities.count).to eql(3)
      end

      it 'serves the yaml relations as expected' do
        expect(subject.countries).to be_a(Relation)
        expect(subject.countries.count).to eql(3)
      end

      it 'supports eaching relations' do
        seen = subject.each_relation_pair.map{|name, rel|
          expect(rel).to be_a(Relation)
          name
        }.sort_by(&:to_s)
        expect(seen).to eql([:cities, :countries, :parts, :suppliers, :supplies])
      end

      it 'supports to_xlsx' do
        subject.to_xlsx(Path.tempfile)
      end

      it 'supports to_data_folder' do
        subject.to_data_folder(Path.tmpdir)
      end

      context 'when using a String path' do
        subject {
          Database.data_folder((Path.dir.parent.parent/'suppliers-and-parts').to_s)
        }

        it 'is served by Database.data_folder' do
          expect(subject).to be_a(DataFolder)
        end

        it 'serves the json relations as expected' do
          expect(subject.suppliers).to be_a(Relation)
          expect(subject.suppliers.count).to eql(5)
        end
      end

    end
  end # class Database
end # module Bmg

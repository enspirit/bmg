require 'spec_helper'

module Bmg
  class Database
    describe "Xlsx" do

      subject {
        Database.xlsx(Path.dir.parent.parent/'suppliers-and-parts.xlsx')
      }

      it 'is served by Database.xlsx' do
        expect(subject).to be_a(Xlsx)
      end

      it 'serves relations as expected' do
        expect(subject.suppliers).to be_a(Relation)
        expect(subject.suppliers.count).to eql(5)
      end

      it 'supports eaching relations' do
        seen = subject.each_relation_pair.map{|name, rel|
          expect(rel).to be_a(Relation)
          name
        }.sort_by(&:to_s)
        expect(seen).to eql([:cities, :countries, :parts, :suppliers, :supplies])
      end

      it 'supports to_xlsx' do
        file = Path('/tmp/test.xlsx')
        subject.to_xlsx(file)
      end

      it 'supports to_data_folder' do
        subject.to_data_folder(Path.tmpdir)
      end
    end
  end # class Database
end # module Bmg

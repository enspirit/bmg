require 'spec_helper'
require 'json'

module Bmg
  class Database
    describe Sequel do

      subject {
        Database.sequel(SpecHelper::SEQUEL_DB)
      }

      it 'is served by Database.sequel' do
        expect(subject).to be_a(Sequel)
      end

      it 'serves the relations as expected' do
        expect(subject.suppliers).to be_a(Relation)
        expect(subject.suppliers.count).to eql(5)
      end

      it 'supports eaching_relations' do
        seen = subject.each_relation_pair.map{|name, rel|
          expect(rel).to be_a(Relation)
          name
        }.sort_by(&:to_s)
        expect(seen).to eql([:cities, :parts, :schema_migrations, :suppliers, :supplies])
      end

      it 'supports to_xlsx' do
        subject.to_xlsx(Path.tempfile)
      end

      it 'supports to_data_folder' do
        subject.to_data_folder(Path.tmpdir)
      end

    end
  end # class Database
end # module Bmg

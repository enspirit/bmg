require 'spec_helper'
module Bmg
  describe Sequel, "SQL translations" do

    class Context

      def initialize(sequel_db)
        @sequel_db = sequel_db
      end
      attr_reader :sequel_db

      def cities_type
        Type::ANY
          .with_attrlist([:city, :country])
      end

      def cities
        Bmg.sequel(:cities, sequel_db, cities_type)
      end

      def suppliers_type
        Type::ANY
          .with_attrlist([:sid, :name, :city, :status])
          .with_keys([[:sid]])
          .with_typecheck
      end

      def suppliers
        Bmg.sequel(:suppliers, sequel_db, suppliers_type)
      end

      def suppliers_dataset
        Bmg.sequel(sequel_db[:suppliers], suppliers_type)
      end

      def parts_type
        Type::ANY
          .with_attrlist([:pid, :name, :color, :weight, :city])
          .with_keys([[:pid]])
          .with_typecheck
      end

      def parts
        Bmg.sequel(:parts, sequel_db, parts_type)
      end

      def supplies_type
        Type::ANY
          .with_attrlist([:sid, :pid, :qty])
          .with_keys([[:sid, :pid]])
          .with_typecheck
      end

      def supplies
        Bmg.sequel(:supplies, sequel_db, supplies_type)
      end

      def native_sids_of_suppliers_in_london
        type = Bmg::Type.new.with_attrlist([:sid])
        Bmg.sequel(sequel_db["SELECT sid FROM suppliers WHERE city = 'London'"], type)
      end

      def compile(test_case)
        self.instance_eval(test_case.bmg)
      end

    end

    def compiled(test_case)
      Context.new(sequel_db).compile(test_case)
    end

    def clean(sql)
      sql.gsub(/[\s\n]+/, " ").gsub(/\(\s*/, "(").gsub(/\s*\)/, ")")
    end

    Path.dir.glob("**/*.yml").each do |file|
      describe "On #{file.basename}" do
        file.load.each do |test_case|
          test_case = OpenStruct.new(test_case)
          describe test_case.bmg do

            it 'compiles to expected SQL for SQlite' do
              compiled = compiled(test_case)
              got = clean(compiled.to_sql)
              expected = clean(test_case.sqlite)
              unless got == expected
                puts
                puts test_case.bmg
                puts got
                puts expected
              end
              expect(got).to eql(expected)
            end

            it 'executes without error directly' do
              sequel_db[compiled(test_case).to_sql].to_a
            end

            it 'executes without error when asked to the relation itself' do
              compiled(test_case).to_a
            end

          end
        end
      end
    end

  end
end

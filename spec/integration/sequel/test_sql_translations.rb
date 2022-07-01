require 'spec_helper'
module Bmg
  describe Sequel, "SQL translations" do

    def compiled(test_case)
      SpecHelper::Context.new(sequel_db).compile(test_case)
    end

    def clean(sql)
      sql.gsub(/[\s\n]+/, " ").gsub(/\(\s*/, "(").gsub(/\s*\)/, ")")
    end

    Path.dir.glob("**/*.yml").each do |file|
      #next unless file.to_s =~ /page/

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

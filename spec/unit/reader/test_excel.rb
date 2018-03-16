require 'spec_helper'
module Bmg
  module Reader
    describe Csv do

      it 'works when the extension is known' do
        file = Path.dir/("example.xlsx")
        xlsx = Excel.new(Type::ANY, file, skip: 1)
        expect(xlsx.to_a).to eql([
          {id: 1, name: "Bernard Lambeau"},
          {id: 2, name: "Yoann Guyot"}
        ])
      end

      it "allows specifying the extension through Roo's option" do
        file = Path.dir/("example.excel")
        xlsx = Excel.new(Type::ANY, file, skip: 1, extension: 'xlsx')
        expect(xlsx.to_a).to eql([
          {id: 1, name: "Bernard Lambeau"},
          {id: 2, name: "Yoann Guyot"}
        ])
      end

    end
  end
end

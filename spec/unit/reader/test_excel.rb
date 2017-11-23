require 'spec_helper'
module Bmg
  module Reader
    describe Csv do

      it 'works' do
        file = Path.dir/("example.xlsx")
        xlsx = Excel.new(file, skip: 1)
        expect(xlsx.to_a).to eql([
          {id: 1, name: "Bernard Lambeau"},
          {id: 2, name: "Yoann Guyot"}
        ])
      end

    end
  end
end

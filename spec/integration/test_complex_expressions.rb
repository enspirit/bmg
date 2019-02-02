require 'spec_helper'
module Bmg
  describe "complex expressions" do

    let(:db) {
      SpecHelper::Context.new(sequel_db)
    }

    let(:suppliers) {
      db.suppliers
    }

    let(:parts) {
      db.parts
    }

    let(:supplies) {
      db.supplies
    }

    it 'works for multiple joins and autowraps' do
      puts supplies
        .tuple_image(suppliers, :supplier, [:sid])
        .tap{|r| r.debug }
        .to_a
        .inspect

      puts supplies
        .tuple_image(suppliers, :supplier, [:sid], out: true)
        .tap{|r| r.debug }
        .to_a
        .inspect

      # supplies
      #   .rename(:sid => :supplier_sid)
      #   .join(suppliers.prefix(:supplier_), [:supplier_sid])
      #   .autowrap
      #   .rename(:pid => :"part$pid")
      #   .tap{|r|
      #     puts "---"
      #     r.debug
      #   }
      #   .join(parts.prefix(:"part$"), [:"part$pid"])
      #   .autowrap(:split => "$")
      #   .tap{|r|
      #     puts "---"
      #     r.debug
      #   }
    end

  end
end
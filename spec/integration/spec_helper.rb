require 'rspec'
require 'bmg'
require 'bmg/sequel'
require 'path'
require 'yaml'
require 'ostruct'

module SpecHelper
  SEQUEL_DB = Sequel.connect("sqlite://#{Path.dir.parent}/suppliers-and-parts.db")

  def sequel_db
    SEQUEL_DB
  end

  class Context

    def initialize(sequel_db)
      @sequel_db = sequel_db
    end
    attr_reader :sequel_db

    def cities_type
      Bmg::Type::ANY
        .with_attrlist([:city, :country])
    end

    def cities
      Bmg.sequel(:cities, sequel_db, cities_type)
    end

    def suppliers_type
      Bmg::Type::ANY
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
      Bmg::Type::ANY
        .with_attrlist([:pid, :name, :color, :weight, :city])
        .with_keys([[:pid]])
        .with_typecheck
    end

    def parts
      Bmg.sequel(:parts, sequel_db, parts_type)
    end

    def supplies_type
      Bmg::Type::ANY
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
end

RSpec.configure do |c|
  c.include SpecHelper
end

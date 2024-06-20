module Bmg
  class Database

    def self.data_folder(*args)
      require_relative 'database/data_folder'
      DataFolder.new(*args)
    end

    def self.sequel(*args)
      require 'bmg/sequel'
      require_relative 'database/sequel'
      Sequel.new(*args)
    end

    def self.xlsx(*args)
      require 'bmg/xlsx'
      require_relative 'database/xlsx'
      Xlsx.new(*args)
    end

    def to_xlsx(*args)
      require 'bmg/xlsx'
      Writer::Xlsx.to_xlsx(self, *args)
    end

    def to_data_folder(*args)
      DataFolder.dump(self, *args)
    end

    def each_relation_pair
      raise NotImplementedError
    end

  end # class Database
end # module Bmg

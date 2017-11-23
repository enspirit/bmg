module Bmg
  module Reader

    def to_a
      to_enum(:each).to_a
    end

  end
end
require_relative "reader/csv"
require_relative "reader/excel"

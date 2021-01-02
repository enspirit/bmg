module Bmg
  module Reader
    include Relation

    attr_accessor :type
    protected :type=

  end
end
require_relative "reader/csv"
require_relative "reader/excel"
require_relative "reader/text_file"

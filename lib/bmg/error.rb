module Bmg

  # Main parent of all Bmg errors
  class Error < StandardError; end

  # Raised by Relation#one when the relation is not a singleton
  class OneError < Error; end

end

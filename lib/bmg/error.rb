module Bmg

  # Main parent of all Bmg errors
  class Error < StandardError; end

  # Raised by Relation#one when the relation is not a singleton
  class OneError < Error; end

  # Raised when an update is invalid for some reason
  class InvalidUpdateError < Error; end

end

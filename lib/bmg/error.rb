module Bmg

  # Main parent of all Bmg errors
  class Error < StandardError; end

  # Raised by Relation#one when the relation is not a singleton
  class OneError < Error; end

  # Raised when an update is invalid for some reason
  class InvalidUpdateError < Error; end

  # Raised when violating types
  class TypeError < Error; end

  # Raised by a type when trying to access attribute list
  # while unknown
  class UnknownAttributesError < Error; end

end

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

  # Raised when an operator is badly used
  class MisuseError < Error; end

  # Raised when some compilation is not supported, as an indicator
  # to backtrack to something more ruby-native.
  class NotSupportedError < Error; end

  # Raised when relation (variable) is not found
  class NotSuchRelationError < Error; end

end

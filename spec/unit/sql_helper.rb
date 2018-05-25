require 'spec_helper'
require 'bmg/sql'

require_relative 'sql/helpers/ast'

RSpec.configure do |c|
  c.include SqlHelpers
  c.extend  SqlHelpers
end

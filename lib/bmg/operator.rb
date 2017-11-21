module Bmg
  module Operator

    def to_a
      to_enum(:each).to_a
    end

  end
end
require_relative 'operator/allbut'
require_relative 'operator/autowrap'
require_relative 'operator/project'
require_relative 'operator/rename'

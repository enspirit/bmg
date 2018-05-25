require 'spec_helper'
module Bmg
  module Operator
    class Autowrap
      describe Support do
        include Support

        it 'has wrapped_roots utility' do
          expect(wrapped_roots([:a], "_")).to eql([])
          expect(wrapped_roots([:a, :b_id, :b_name], "_")).to eql([:b])
          expect(wrapped_roots([:a, :b_id, :c_x_id], "_")).to eql([:b, :c])
          expect(wrapped_roots([:a, :"b-id", :"c-x-id"], "-")).to eql([:b, :c])
        end

      end
    end
  end
end

require 'spec_helper'
module Bmg
  module Operator
    describe Autowrap, "same_options?" do

      it 'default options are equal to nothing' do
        a = Autowrap.new(Type::ANY, [])
        expect(a.same_options?({})).to eql(true)
      end 

      it 'split options are equal' do
        a = Autowrap.new(Type::ANY, [], :split => "-")
        expect(a.same_options?(:split => "-")).to eql(true)
      end 

      it 'different split yield non equal options' do
        a = Autowrap.new(Type::ANY, [], :split => "_")
        expect(a.same_options?(:split => "-")).to eql(false)
      end 

    end
  end
end

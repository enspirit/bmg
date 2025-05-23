require 'spec_helper'
module Bmg
  module Operator
    describe Generator do

      it 'works' do
        g = Generator.new(Type::ANY, 2, 4)
        expect(g.to_a).to eql([
          { i: 2 },
          { i: 3 },
          { i: 4 },
        ])
      end

      it 'supports an :as' do
        g = Generator.new(Type::ANY, 2, 4, :as => :j)
        expect(g.to_a).to eql([
          { j: 2 },
          { j: 3 },
          { j: 4 },
        ])
      end

      it 'supports a implicit step' do
        g = Generator.new(Type::ANY, 1, 4, 2)
        expect(g.to_a).to eql([
          { i: 1 },
          { i: 3 },
        ])
      end

      it 'supports a step' do
        g = Generator.new(Type::ANY, 1, 4, step: 2)
        expect(g.to_a).to eql([
          { i: 1 },
          { i: 3 },
        ])
      end

      it 'return empty on reversed args' do
        g = Generator.new(Type::ANY, 4,3)
        expect(g.to_a).to eql([
        ])
      end

      it 'supports floats' do
        g = Generator.new(Type::ANY, 1.1, 4, step: 1.3)
        expect(g.to_a).to eql([
          { i: 1.1 },
          { i: 1.1+1.3 },
          { i: 1.1+1.3+1.3 },
        ])
      end

      it 'supports a reverse mechanism' do
        g = Generator.new(Type::ANY, 5, 1, step: -2)
        expect(g.to_a).to eql([
          { i: 5 },
          { i: 3 },
          { i: 1 },
        ])
      end

      it 'supports a step lambda' do
        g = Generator.new(Type::ANY, 1, 13, step: ->(i){ i+5 })
        expect(g.to_a).to eql([
          { i: 1 },
          { i: 6 },
          { i: 11 },
        ])
      end

      it 'supports non numeric values' do
        g = Generator.new(Type::ANY, Date.new(2025,1,1), Date.new(2025,1,3))
        expect(g.to_a).to eql([
          { i: Date.new(2025,1,1) },
          { i: Date.new(2025,1,2) },
          { i: Date.new(2025,1,3) },
        ])
      end

      it 'robust' do
        expect {
          Generator.new(Type::ANY, nil, 4)
        }.to raise_error(ArgumentError)
        expect {
          Generator.new(Type::ANY, 1, nil)
        }.to raise_error(ArgumentError)
      end

    end
  end
end

require 'rspec'
module Bmg
  describe TupleAlgebra, "allbut" do
    include TupleAlgebra

    it 'works' do
      expect(allbut({a: 1, b: 2}, [:b])).to eql({a: 1})
    end

    it 'ignores unexisting attributes' do
      expect(allbut({a: 1, b: 2}, [:b, :c])).to eql({a: 1})
    end

    it 'does not change the original' do
      original = {a: 1, b: 2}
      expect(allbut(original, [:b])).to eql({a: 1})
      expect(original).to eql({a: 1, b: 2})
    end

  end
  describe TupleAlgebra, "project" do
    include TupleAlgebra

    it 'works' do
      expect(project({a: 1, b: 2}, [:a])).to eql({a: 1})
    end

    it 'ignores unexisting attributes' do
      expect(project({a: 1, b: 2}, [:a, :c])).to eql({a: 1})
    end

    it 'does not change the original' do
      original = {a: 1, b: 2}
      expect(project(original, [:a])).to eql({a: 1})
      expect(original).to eql({a: 1, b: 2})
    end

  end
end

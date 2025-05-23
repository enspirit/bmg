require 'spec_helper'

describe "Bmg's README" do

  describe 'generate' do
    it 'has a correct first example' do
      r = Bmg
        .generate(1, 10, :step => 2, :as => :index)
        .restrict(:index => 5)
      expect(r.count).to eql(1)
      expect(r.one).to eql({ index: 5 })
    end

    it 'has a correct second example' do
      r = Bmg.generate(10, 1, :step => -2, :as => :index)
      expect(r.count).to eql(5)
    end

    it 'has a correct third example' do
      r = Bmg.generate(1, 100, :step => ->(current){ current * 2 })
      expect(r.count).to eql([1, 2, 4, 8, 16, 32, 64].size)
    end

    it 'has a correct last example' do
      min = Date.new(2025,5,1)
      max = Date.new(2025,12,1)
      r = Bmg.generate(min, max, :step => ->(current){ current.next_month })
      expect(r.count).to eql(8)
    end
  end

end

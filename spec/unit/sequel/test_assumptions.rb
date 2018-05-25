require 'spec_helper'
describe "Assumptions about Sequel" do

  it 'supports matching where' do
    london_suppliers = sequel_db[:suppliers]
      .where{|t| t.city.like("Lon%") }
      .to_a
    expect(london_suppliers.size).to eql(2)
  end

end

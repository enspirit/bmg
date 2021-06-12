require 'spec_helper'
module Bmg
  describe Sequel, "summarize" do

    let(:db) {
      SpecHelper::Context.new(sequel_db)
    }

    it 'does compile supported transformation' do
      got = db.suppliers
        .transform(:status => String)
      expect(got).to be_a(Sequel::Relation)
      expect(got.to_a.map{|t| t[:status] }.sort).to eql(["10","20","20","30","30"])
    end

    it 'does not compile unsupported transformation' do
      got = db.supplies
        .transform(:qty => ->(t){ t[:qty] * 2 })
      expect(got).to be_a(Operator::Transform)
      expect(got.send(:operand)).to be_a(Sequel::Relation)
    end

    it 'is able to split supported and unsupported transformations' do
      t = { :sid => ->(sid){ sid.downcase }, :qty => String}
      got = db.supplies.transform(t)
      expect(got).to be_a(Operator::Transform)
      expect(got.send(:transformation)).to eql(:sid => t[:sid])
      expect(got.send(:operand)).to be_a(Sequel::Relation)
      expect(got.to_a.all?{|t| t[:sid] =~ /^s/ && t[:qty].is_a?(String) }).to eql(true)
    end

  end
end

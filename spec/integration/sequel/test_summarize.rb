require 'spec_helper'
module Bmg
  describe Sequel, "summarize" do

    let(:db) {
      SpecHelper::Context.new(sequel_db)
    }

    it 'does not compile unsupported summarizations' do
      got = db.supplies
        .summarize([], :qty => :collect)
      expect(got).to be_a(Operator::Summarize)
    end

  end
end


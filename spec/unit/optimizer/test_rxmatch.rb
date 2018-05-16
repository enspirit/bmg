require 'spec_helper'
module Bmg
  describe "rxmatch optimization" do

    context "rxmatch.restrict" do

      let(:predicate) {
        Predicate.gt(:b, 2)
      }

      subject {
        Relation.new([
          { a: "foo",  b: 2 },
          { a: "bar",  b: 2 }
        ]).rxmatch([:a], /foo/, {:hello => "world", :case_sensitive=>true}).restrict(predicate)
      }

      it 'works' do
        expect(subject).to be_a(Operator::Rxmatch)
        expect(subject.send(:attrs)).to eql([:a])
        expect(subject.send(:matcher)).to eql(/foo/)
        expect(subject.send(:options)).to eql({:hello => "world", :case_sensitive=>true})
        expect(operand).to be_a(Operator::Restrict)
        expect(predicate_of(operand)).to eql(predicate)
      end
    end

  end
end

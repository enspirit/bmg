require 'spec_helper'
module Bmg
  describe TupleTransformer do

    let(:tuple){{
      :foo => 2,
      :bar => "a",
      :baz => "1"
    }}

    describe "new" do
      it "returns a Transformer instance by default" do
        expect(TupleTransformer.new(:to_s)).to be_a(TupleTransformer)
      end

      it "returns the Transformer arg, for easy coercion" do
        t = TupleTransformer.new(:to_s)
        expect(TupleTransformer.new(t)).to be(t)
      end
    end

    describe "call" do
      subject{
        TupleTransformer.new(arg).call(tuple)
      }

      context 'when used with a Symbol' do
        let(:arg){
          :to_s
        }

        it 'works' do
          expect(subject).to eql({
            foo: "2",
            bar: "a",
            baz: "1"
          })
        end
      end

      context 'when used with a Regexp' do
        let(:arg){
          /[a-z]/
        }

        it 'works' do
          expect(subject).to eql({
            foo: nil,
            bar: "a",
            baz: nil
          })
        end
      end

      context 'when used with an Array of Symbols' do
        let(:arg){
          [:to_s, :upcase]
        }

        it 'works' do
          expect(subject).to eql({
            foo: "2",
            bar: "A",
            baz: "1"
          })
        end
      end

      context 'when used with a Proc' do
        let(:arg){
          ->(attr){ attr.to_s }
        }

        it 'works' do
          expect(subject).to eql({
            foo: "2",
            bar: "a",
            baz: "1"
          })
        end
      end

      context 'when used with a Hash with various transformers' do
        let(:arg){{
          :foo => :to_s,
          :bar => ->(attr){ attr.upcase },
          :baz => { "1" => "a", "2" => "b" }
        }}

        it 'works' do
          expect(subject).to eql({
            foo: "2",
            bar: "A",
            baz: "a"
          })
        end
      end
    end

  end
end

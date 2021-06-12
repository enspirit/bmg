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

      context 'when used with a Hash with types to transformers' do
        let(:arg){{
          Integer => :to_s,
          String => :capitalize
        }}

        it 'works' do
          expect(subject).to eql({
            foo: "2",
            bar: "A",
            baz: "1"
          })
        end
      end

      context 'when used with a class' do
        let(:tuple){{
          :int => "1",
          :float => "2.3",
          :date => "2021-01-04",
          :datetime => "2021-01-04T13:06:21",
          :string => 12,
          #
          :warn => nil
        }}
        let(:arg){
          {
            :int => Integer,
            :float => Float,
            :date => Date,
            :datetime => DateTime,
            :string => String,
            #
            :warn => Date
          }
        }

        it 'works' do
          expect(subject).to eql({
            int: 1,
            float: 2.3,
            date: Date.parse(tuple[:date]),
            datetime: DateTime.parse("2021-01-04T13:06:21"),
            string: "12",
            #
            warn: nil
          })
        end
      end

      context 'when used with an unsupported class' do
        let(:arg){ TupleTransformer }

        it 'raises' do
          expect{ subject }.to raise_error(ArgumentError)
        end
      end

    end

  end
end

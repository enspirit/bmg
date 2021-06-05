require 'spec_helper'
module Bmg
  class Summarizer
    describe ValueBy do

      let(:rel){[
        {:serie => "foo", :qty => 10},
        {:serie => "bar", :qty => 20},
        {:serie => "baz", :qty => 30}
      ]}

      context 'with default options' do
        let(:value_by){
          ValueBy.new(:qty, :by => :serie)
        }

        it 'should work when used standalone' do
          expect(value_by.summarize(rel)).to eql({
            "foo" => 10,
            "bar" => 20,
            "baz" => 30
          })
        end
      end

      context 'with symbolization' do
        let(:value_by){
          ValueBy.new(:qty, :by => :serie, :symbolize => true)
        }

        it 'should work when used standalone' do
          expect(value_by.summarize(rel)).to eql({
            :foo => 10,
            :bar => 20,
            :baz => 30
          })
        end
      end

      context 'passing series' do
        let(:value_by){
          ValueBy.new(:qty, :by => :serie, :symbolize => true, :series => [:foo, :bar, :baz, :bro])
        }

        it 'should work when used standalone' do
          expect(value_by.summarize(rel)).to eql({
            :foo => 10,
            :bar => 20,
            :baz => 30,
            :bro => nil
          })
        end
      end

      context 'with an empty relation an no default no series' do
        let(:value_by){
          ValueBy.new(:qty, :by => :serie)
        }

        let(:rel){[
        ]}

        it 'raises an error' do
          expect(value_by.summarize(rel)).to eql({})
        end
      end

      context 'with an empty relation and a default and series' do
        let(:value_by){
          ValueBy.new(:qty, :by => :serie, :default => 0, :series => [:foo, :bar])
        }

        let(:rel){[
        ]}

        it 'raises an error' do
          expect(value_by.summarize(rel)).to eql({:foo => 0, :bar => 0})
        end
      end

      context 'when not a candidate key' do
        let(:value_by){
          ValueBy.new(:qty, :by => :serie)
        }

        let(:rel){[
          {:serie => "foo", :qty => 10},
          {:serie => "bar", :qty => 20},
          {:serie => "bar", :qty => 30}
        ]}

        it 'raises an error' do
          expect{ value_by.summarize(rel) }.to raise_error(MisuseError)
        end
      end

    end
  end
end

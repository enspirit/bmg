require 'spec_helper'
module Bmg
  module Operator
    describe 'Autowrap' do

      context 'when called in default mode' do

        it 'works as an array by default' do
          autowrap = Autowrap.new Type::ANY, [{ a: 1, b: 2 }]
          expect(autowrap.to_a).to eql([{ a: 1, b: 2 }])
        end

        it 'wrap levels 1' do
          autowrap = Autowrap.new Type::ANY, [{ a: 1, b_x: 2, b_y: 3 }]
          expect(autowrap.to_a).to eql([{ a: 1, b: { x: 2, y: 3 } }])
        end

        it 'wrap levels 2' do
          autowrap = Autowrap.new Type::ANY, [{ a: 1, b_x_u: 2, b_y_v: 3, b_y_w: 4 }]
          expect(autowrap.to_a).to eql([{ a: 1, b: { x: { u: 2 }, y: { v: 3, w: 4 } } }])
        end

        it 'keeps LEFT JOIN nils unchanged' do
          autowrap = Autowrap.new Type::ANY, [{ a: 1, b_x: nil, b_y: nil }]
          expect(autowrap.to_a).to eql([{ a: 1, b: { x: nil, y: nil } }])
        end

      end

      context 'when specifying the separator to use' do

        it 'works as expected' do
          autowrap = Autowrap.new Type::ANY, [{ :a => 1, :"b.x.u" => 2, "b.y.v" => 3, "b.y.w" => 4 }], split: '.'
          expect(autowrap.to_a).to eql([{ a: 1, b: { x: { u: 2 }, y: { v: 3, w: 4 } } }])
        end

      end

      context 'when called with a Proc post processor' do

        let(:post) {
          ->(t,_){ t.delete(:user) if t[:user][:id].nil?; t }
        }

        it 'wrap levels 2' do
          aw = Autowrap.new Type::ANY, [
            { user_id: 1, user_name: "foo", foo: "bar" },
            { user_id: nil, user_name: nil, foo: "baz" }
          ], postprocessor: post
          expected = [
            { user: {id: 1, name: "foo"}, foo: "bar" },
            { foo: "baz" }
          ]
          expect(aw.to_a).to eql(expected)
        end

      end

      context 'when called with :delete post processor' do

        it 'automatically removes the results of nil LEFT JOINs' do
          autowrap = Autowrap.new Type::ANY, [{ a: 1, b_x: nil, b_y: nil }], postprocessor: :delete
          expect(autowrap.to_a).to eql([{ a: 1 }])
        end

      end

      context 'when called with :nil post processor' do

        it 'sets the results of nil LEFT JOINs to nil' do
          autowrap = Autowrap.new Type::ANY, [{ a: 1, b_x: nil, b_y: nil }], postprocessor: :nil
          expect(autowrap.to_a).to eql([{ a: 1, b: nil }])
        end

      end

      context 'when called with a Hash post processor' do

        it 'sets the results of nil LEFT JOINs to nil' do
          autowrap = Autowrap.new Type::ANY, [{ a: 1, b_x: nil, b_y: nil, c_x: nil, c_y: nil, d_x: nil }], postprocessor: { b: :nil, c: :delete }
          expect(autowrap.to_a).to eql([{ a: 1, b: nil, d: { x: nil } }])
        end

      end

    end
  end
end

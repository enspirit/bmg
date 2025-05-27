require 'spec_helper'
module Bmg
  describe Type do

    let(:any){ Type::ANY }

    let(:suppliers_attrlist) {
      [:sid, :name, :status, :city]
    }

    let(:suppliers){
      Type::ANY.with_attrlist(suppliers_attrlist)
    }

    let(:supplies_attrlist) {
      [:sid, :pid, :qty]
    }

    let(:supplies){
      Type::ANY.with_attrlist(supplies_attrlist)
    }

    it 'lets specifying the attributes' do
      type = any.with_attrlist([:a, :b])
      expect(type).to be_a(Type)
      expect(type.knows_attrlist?).to be(true)
      expect(type.to_attrlist).to eql([:a, :b])
    end

    it 'has a default key as soon as it has attributes' do
      expect(any.keys).to be_nil
      expect(any.with_attrlist([:id, :name]).keys).to eql([[:id, :name]])
      expect(suppliers.keys).to eql([suppliers_attrlist])
    end

    it 'lets specifying the keys' do
      type = any.with_keys([[:id]])
      expect(type).to be_a(Type)
      expect(type.keys).to eq([[:id]])
    end

    it 'lets specifying a heading with with_heading' do
      type = any.with_heading(id: Integer, name: String)
      expect(type).to be_a(Type)
      expect(type.knows_attrlist?).to be(true)
      expect(type.to_attrlist).to eql([:id, :name])
    end

    it 'lets building from an heading' do
      type = Type.for_heading(id: Integer, name: String)
      expect(type).to be_a(Type)
      expect(type.knows_attrlist?).to be(true)
      expect(type.to_attrlist).to eql([:id, :name])
    end

    describe 'allbut' do

      it 'reduces the attrlist when known' do
        type = suppliers.allbut([:name, :city])
        expect(type.knows_attrlist?).to be(true)
        expect(type.to_attrlist).to eq([:sid, :status])
      end

      it 'keeps any key that is still valid' do
        type = suppliers.with_keys([[:sid], [:city, :name]])
        expect(type.allbut([:name]).keys).to eql([[:sid]])
        expect(type.allbut([:status]).keys).to eql([[:sid], [:city, :name]])
        expect(type.allbut([:sid, :city]).keys).to eql([[:name, :status]])
      end

    end

    describe 'autowrap' do

      it 'preserves the predicate if possible' do
        predicate = Predicate.eq(:sid, "S1")
        type = suppliers.with_predicate(predicate).autowrap({})
        expect(type.predicate).to eql(predicate)
      end

      it 'splits the predicate if possible' do
        left = Predicate.eq(:sid, "S1")
        right = Predicate.eq(:supplied_name, "Smith")
        type = suppliers.with_predicate(left & right).autowrap({})
        expect(type.predicate).to eql(left)
      end

      it 'autowraps the attrlist when known' do
        type = suppliers.with_attrlist([:name, :city, :part_pid, :part_name]).autowrap({})
        expect(type.knows_attrlist?).to be(true)
        expect(type.to_attrlist).to eq([:name, :city, :part])
      end

      it 'keeps the keys that are not touched' do
        type = suppliers.with_keys([[:sid]]).autowrap({})
        expect(type.keys).to eql([[:sid]])
      end

      it 'converts autowrapped key attributes by the newly introduced attribute' do
        type = suppliers.with_keys([[:supplier_sid, :name]]).autowrap({})
        expect(type.keys).to eql([[:supplier, :name]])
      end

    end

    describe 'constants' do

      it 'extends attrlist when known' do
        type = suppliers.constants(newone: 3, newtwo: 2)
        expect(type.knows_attrlist?).to be(true)
        expect(type.to_attrlist).to eq(suppliers_attrlist + [:newone, :newtwo])
      end

      it 'keeps the keys' do
        base = any.constants(newone: 3, newtwo: 2)
        expect(base.keys).to be_nil
        type = base.with_keys([[:id]])
        expect(type.keys).to eql([[:id]])
      end

    end

    describe 'extends' do

      it 'extends attrlist when known' do
        type = suppliers.extend(newone: ->{}, newtwo: ->{})
        expect(type.knows_attrlist?).to be(true)
        expect(type.to_attrlist).to eq(suppliers_attrlist + [:newone, :newtwo])
      end

    end

    describe 'group' do

      it 'reworks attrlist when known' do
        type = suppliers.group([:status, :city], :group)
        expect(type.knows_attrlist?).to be(true)
        expect(type.to_attrlist).to eq(suppliers_attrlist - [:status, :city] + [:group])
      end

      it 'keeps keys entirely ungrouped' do
        type = suppliers.with_keys([[:sid]]).group([:status, :city], :group)
        expect(type.keys).to eql([[:sid]])
      end

      it 'handles the whole key being grouped' do
        type = suppliers.with_keys([[:sid]]).group([:sid, :name, :status], :living)
        expect(type.keys).to eql([[:city], [:living]])
      end

      it 'reduces a splitted key having groupby inside' do
        type = suppliers.with_keys([[:status, :city]]).group([:sid, :name, :status], :living)
        expect(type.keys).to eql([[:city]])
      end

      it 'handles the key being split' do
        type = suppliers.with_keys([[:name, :city]]).group([:name, :status], :living)
        expect(type.keys).to eql([[:sid, :city], [:city, :living]])
      end

    end

    describe 'image' do

      it 'reworks attrlist when known' do
        type = suppliers.image(suppliers, :image_name, [:sid, :city], {})
        expect(type.knows_attrlist?).to be(true)
        expect(type.to_attrlist).to eq(suppliers_attrlist + [:image_name])
      end

      it 'keeps the original keys' do
        type = suppliers.with_keys([[:sid]]).image(suppliers, :image_name, [:sid, :city], {})
        expect(type.keys).to eql([[:sid]])
      end

    end

    describe 'join' do

      it 'extends the attrlist when both are known' do
        type = suppliers.join(supplies, [:sid])
        expect(type.knows_attrlist?). to be(true)
        expect(type.to_attrlist).to eq(suppliers_attrlist + [:pid, :qty])
      end

      it 'computes the resulting keys as expected' do
        ltype = supplies.with_keys([[:sid, :pid]])
        rtype = suppliers.with_keys([[:sid], [:name, :city]])
        type = ltype.join(rtype, [:sid])
        expect(type.keys).to eql([[:sid, :pid]])
      end

      it 'is smart when joining towards a candidate key on right' do
        ltype = suppliers.with_keys([[:sid]])
        rtype = any.with_attrlist([:city, :peopleCount]).with_keys([[:city]])
        type  = ltype.join(rtype, [:city])
        expect(type.keys).to eql([[:sid]])
      end

      it 'is smart when joining on more that the candidate key on right' do
        ltype = suppliers.with_keys([[:sid]])
        rtype = any.with_attrlist([:city, :name, :peopleCount]).with_keys([[:city]])
        type  = ltype.join(rtype, [:city, :name])
        expect(type.keys).to eql([[:sid]])
      end

    end

    describe 'project' do

      it 'sets the attrlist when unknown' do
        type = any.project([:name, :city])
        expect(type.knows_attrlist?).to be(true)
        expect(type.to_attrlist).to eq([:name, :city])
      end

      it 'sets the attrlist when already known' do
        type = suppliers.project([:name, :city])
        expect(type.knows_attrlist?).to be(true)
        expect(type.to_attrlist).to eq([:name, :city])
      end

      it 'keeps non projected keys' do
        type = suppliers.with_keys([[:sid], [:status, :city]]).project([:sid, :name, :status])
        expect(type.keys).to eql([[:sid]])
      end

    end

    describe 'rename' do

      it 'renames the predicate' do
        type = suppliers.restrict(Predicate.eq(:sid, 'S2')).rename(:sid => :id)
        expect(type.predicate).to eql(Predicate.eq(:id => 'S2'))
      end

      it 'renames the attrlist when known' do
        type = suppliers.with_attrlist([:sid, :name]).rename(:sid => :id)
        expect(type.to_attrlist).to eql([:id, :name])
      end

      it 'renames the keys when known' do
        type = suppliers.with_keys([[:sid], [:name, :status]]).rename(:sid => :id, :status => :ss)
        expect(type.keys).to eql([[:id], [:name, :ss]])
      end

      it 'supports a Predicate::NotSupportedError' do
        type = suppliers.restrict(Predicate.native(->(t){ false })).rename(:sid => :id)
        expect(type.predicate).to eql(Predicate.tautology)
      end

    end

    describe 'restrict' do

      it 'keeps attrlist when known' do
        type = suppliers.restrict(Predicate.eq(:sid, "S1"))
        expect(type.knows_attrlist?).to be(true)
        expect(type.to_attrlist).to eq(suppliers_attrlist)
      end

      it 'keeps keys when known' do
        type = suppliers.with_keys([[:sid]]).restrict(Predicate.eq(:name, "Smith"))
        expect(type.keys).to eql([[:sid]])
      end

      it 'restrict keys according to predicate invariant' do
        type = suppliers.with_keys([[:sid]]).restrict(Predicate.eq(:sid, "S1"))
        expect(type.keys).to eql([[]])
        type = supplies.with_keys([[:pid, :sid]]).restrict(Predicate.eq(:sid, "S1"))
        expect(type.keys).to eql([[:pid]])
      end

      it 'does not do it if restriction is not a constant' do
        type = supplies
          .with_keys([[:pid, :sid]])
        [
          Predicate.eq(:sid, "S1") | Predicate.eq(:sid, "S2"),
          Predicate.in(:sid, ["S1", "S2"]),
          Predicate.neq(:sid, "S1"),
          Predicate.gt(:sid, "S1")
        ].each do |p|
          expect(type.restrict(p).allbut([:sid]).keys).to eql([[:pid, :qty]])
        end
      end

    end

    describe 'summarize' do

      it 'sets attrlist since they are known' do
        type = any.summarize([:a], { b: :sum })
        expect(type.knows_attrlist?).to be(true)
        expect(type.to_attrlist).to eq([:a, :b])
      end

      it 'sets by as the key' do
        type = any.summarize([:a], { b: :sum })
        expect(type.keys).to eql([[:a]])
      end

    end

    describe 'transform' do

      it 'keeps attrlist' do
        type = suppliers.transform(:to_s)
        expect(type.to_attrlist).to eql(suppliers.to_attrlist)
      end

      it 'drops all keys by default' do
        type = suppliers
          .with_keys([[:sid]])
          .transform(:to_s)
        expect(type.keys).to eql([suppliers.to_attrlist])
      end

      it 'drops predicate by default' do
        type = suppliers
          .with_predicate(Predicate.eq(:sid, "S1"))
          .transform(:to_s)
        expect(type.predicate).to eql(Predicate.tautology)
      end

      it 'preserves the keys when explicitely requested' do
        type = suppliers
          .with_keys([[:sid]])
          .transform(:to_s, key_preserving: true)
        expect(type.keys).to eql([[:sid]])
      end

      it 'detects wrong usages when typechecked is set' do
        expect {
          suppliers
          .with_typecheck
          .transform(:foo => :to_s)
        }.to raise_error(TypeError)
      end

      it 'automatically preserves untouched keys' do
        type = suppliers
          .with_keys([[:sid]])
          .transform(:name => :upcase)
        expect(type.keys).to eql([[:sid]])
      end

      it 'automatically preserves predicate when possible' do
        pred = Predicate.eq(:sid, "S2") & Predicate.eq(:name, "Smith")
        type = suppliers
          .with_predicate(pred)
          .transform(:name => :upcase)
        expect(type.predicate).to eql(Predicate.eq(:sid, "S2"))
      end

    end

    describe 'ungroup' do
      let(:type){
        Type::ANY
          .with_attrlist([:sid, :name, :supplies])
          .with_keys([[:sid]])
      }

      it 'drops attrlist' do
        got = type.ungroup([:supplies])
        expect(got.to_attrlist).to be_nil
      end

      it "drop keys" do
        got = type.ungroup([:supplies])
        expect(got.keys).to be_nil
      end

      it 'drops predicate' do
        got = type.ungroup([:supplies])
        expect(got.predicate).to eql(Predicate.tautology)
      end
    end

    describe 'union' do

      it 'keeps attrlist when known' do
        type = suppliers.union(suppliers)
        expect(type.knows_attrlist?).to be(true)
        expect(type.to_attrlist).to eq(suppliers_attrlist)
      end

      it 'removes all keys by default' do
        type = suppliers.with_keys([[:sid]]).union(suppliers)
        expect(type.keys).to eql([suppliers_attrlist])
      end

      it 'keeps the shared keys when predicate is disjoint' do
        t1 = suppliers.restrict(Predicate.eq(:sid, 'S1')).with_keys([[:sid], [:status, :city]])
        t2 = suppliers.restrict(Predicate.eq(:sid, 'S2')).with_keys([[:sid], [:name, :city]])
        expect(t1.union(t2).keys).to eql([[:sid]])
      end

    end

    describe 'unwrap' do
      let(:type){
        Type::ANY
          .with_attrlist([:sid, :name, :supplies])
          .with_keys([[:sid], [:sid, :supplies]])
      }

      it 'drops attrlist' do
        got = type.unwrap([:supplies])
        expect(got.to_attrlist).to be_nil
      end

      it 'keeps keys that don\'t use the wrapped attribute' do
        got = type.unwrap([:supplies])
        expect(got.keys).to eql([[:sid]])
      end

      it 'keeps predicate if it did not use the unwrapped attribute' do
        from = type
          .with_predicate(Predicate.eq(:sid, "S1"))
        got = from
          .unwrap([:supplies])
        expect(got.predicate).to eql(from.predicate)
      end

      it 'split AND-predicate using the unwrapped attribute' do
        from = type
          .with_predicate(Predicate.eq(:sid, "S1") & Predicate.neq(:supplies, nil))
        got = from
          .unwrap([:supplies])
        expect(got.predicate).to eql(Predicate.eq(:sid, "S1"))
      end

      it 'drops OR-predicate using the unwrapped attribute' do
        from = type
          .with_predicate(Predicate.eq(:sid, "S1") | Predicate.neq(:supplies, nil))
        got = from
          .unwrap([:supplies])
        expect(got.predicate).to eql(Predicate.tautology)
      end
    end

  end
end

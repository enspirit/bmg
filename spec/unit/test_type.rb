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

    end

    describe 'restrict' do

      it 'keeps attrlist when known' do
        type = suppliers.restrict(Predicate.eq(:sid, "S1"))
        expect(type.knows_attrlist?).to be(true)
        expect(type.to_attrlist).to eq(suppliers_attrlist)
      end

      it 'keeps keys when known' do
        type = suppliers.with_keys([[:sid]]).restrict(Predicate.eq(:sid, "S1"))
        expect(type.keys).to eql([[:sid]])
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

  end
end

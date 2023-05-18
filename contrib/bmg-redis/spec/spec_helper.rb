require 'rspec'
require 'bmg'
require 'bmg/redis'

module SpecHelpers

  def redis
    @redis ||= Redis.new
  end

  def suppliers
    [
      { sid: 'S1', name: 'Smith', city: 'Paris' },
      { sid: 'S2', name: 'Jones', city: 'London' }
    ]
  end

  def suppliers_type
    Bmg::Type::ANY
      .with_attrlist([:sid, :name, :city])
      .with_keys([[:sid]])
  end

  def suppliers_relvar(type = suppliers_type)
    rv = Bmg::Redis::Relation.new(type, {
      redis: redis,
      key_prefix: "suppliers",
    })
    rv.insert(suppliers)
    rv
  end

  def large_relvar_type
    Bmg::Type::ANY
      .with_attrlist([:id])
      .with_keys([[:id]])
  end

  def large_relvar(type = large_relvar_type)
    rv = Bmg::Redis::Relation.new(type, {
      redis: redis,
      key_prefix: "large",
    })
    rv.insert((1..1000).map{|i| { id: i } })
    rv
  end

end

RSpec.configure do |c|
  c.include SpecHelpers
end

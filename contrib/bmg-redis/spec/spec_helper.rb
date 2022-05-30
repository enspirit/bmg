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
    rv = Bmg::Redis::Relation.new(type, { redis: redis })
    rv.insert(suppliers)
    rv
  end

end

RSpec.configure do |c|
  c.include SpecHelpers
end

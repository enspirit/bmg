module Bmg
  module Factory
    def empty(type = Type::ANY)
      raise ArgumentError, "Missing type" if type.nil?
      Relation::Empty.new(type)
    end

    def mutable(enumerable, type = Type::ANY)
      Relation::InMemory::Mutable.new(type, enumerable).spied(Bmg.main_spy)
    end

    def in_memory(enumerable, type = Type::ANY)
      Relation::InMemory.new(type, enumerable).spied(Bmg.main_spy)
    end

    def generate(from, to, options = {})
      type = Type::ANY.with_attrlist([options[:as] || Operator::Generator::DEFAULT_OPTIONS[:as]])
      Operator::Generator.new(type, from, to, options)
    end

    def text_file(path, options = {}, type = Type::ANY)
      Reader::TextFile.new(type, path, options).spied(Bmg.main_spy)
    end

    def csv(path, options = {}, type = Type::ANY)
      Reader::Csv.new(type, path, options).spied(Bmg.main_spy)
    end

    def json_file(path, options = {}, type = Type::ANY)
      in_memory(path.load.map{|tuple| TupleAlgebra.symbolize_keys(tuple) })
    end

    def json(*args, &bl)
      json_file(*args, &bl)
    end

    def yaml_file(path, options = {}, type = Type::ANY)
      in_memory(path.load.map{|tuple| TupleAlgebra.symbolize_keys(tuple) })
    end

    def yaml(*args, &bl)
      yaml_file(*args, &bl)
    end

    def excel_file(path, options = {}, type = Type::ANY)
      Reader::Excel.new(type, path, options).spied(Bmg.main_spy)
    end

    def excel(*args, &bl)
      excel_file(*args, &bl)
    end
  end
end

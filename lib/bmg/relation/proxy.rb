module Bmg
  module Relation
    #
    # This module can be used to create typed collection on top
    # of Bmg relations. Algebra methods will be delegated to the
    # decorated relation, and results wrapped in a new instance
    # of the class.
    #
    module Proxy

      def initialize(relation)
        @relation = relation
      end

      def method_missing(name, *args, &bl)
        if @relation.respond_to?(name)
          res = @relation.send(name, *args, &bl)
          res.is_a?(Relation) ? _proxy(res) : res
        else
          super
        end
      end

      def respond_to?(name, *args)
        @relation.respond_to?(name) || super
      end

      [
        :extend
      ].each do |name|
        define_method(name) do |*args, &bl|
          res = @relation.send(name, *args, &bl)
          res.is_a?(Relation) ? _proxy(res) : res
        end
      end

      [
        :one,
        :one_or_nil
      ].each do |meth|
        define_method(meth) do |*args, &bl|
          res = @relation.send(meth, *args, &bl)
          res.nil? ? nil : _proxy_tuple(res)
        end
      end

      def to_json(*args, &bl)
        @relation.to_json(*args, &bl)
      end

    protected

      def _proxy(relation)
        self.class.new(relation)
      end

      def _proxy_tuple(tuple)
        tuple
      end

    end # module Proxy
  end # class Relation
end # module Bmg

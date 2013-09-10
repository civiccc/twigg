module Twigg
  class Decorator < BasicObject
    def initialize(decorated)
      @decorated = decorated
    end

    def method_missing(method, *args, &block)
      @decorated.send(method, *args, &block)
    end
  end
end

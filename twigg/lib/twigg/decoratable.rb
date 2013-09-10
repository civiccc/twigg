module Twigg
  module Decoratable
    def decorate
      klass = self.class.instance_variable_get('@decorator_class')

      if !klass
        components = (self.class.name + 'Decorator').split('::')
        klass = components.inject(Object) do |namespace, klass|
          namespace.const_get(klass)
        end
        self.class.instance_variable_set('@decorator_class', klass)
      end

      klass.new(self)
    end
  end
end

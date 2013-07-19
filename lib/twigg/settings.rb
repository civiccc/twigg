require 'ostruct'

module Twigg
  # Simple OpenStruct subclass with some methods overridden in order to provide
  # more detailed feedback in the event of a misconfiguration, or to provide
  # reasonable default values.
  #
  # For example, we override `repositories_directory` so that we can report to
  # the user that:
  #
  #   - the setting is missing from the configuration file
  #   - the setting does not point at a directory
  #
  # We override `app.bind` so that we can supply a reasonable default when the
  # configuration file has no value set.
  class Settings < OpenStruct
    class << self
      attr_reader :overrides

    private
      # DSL method for declaring settings underneath a namespace.
      #
      # Example:
      #
      #   namespace :app do
      #     setting :bind, default: '0.0.0.0'
      #   end
      #
      # Note: nesting namespaces is not supported.
      def namespace(scope, &block)
        @namespace = scope
        yield
      ensure
        @namespace = nil
      end

      # DSL method which is used to create a reader for the setting `name`. If
      # the configuration file does not contain a value for the setting, return
      # `options[:default]` from the `options` hash.
      #
      # A block maybe provided to do checking of the supplied value prior to
      # returning; for an example, see the `repositories_directory` setting in
      # this file.
      #
      # Note that this method doesn't actually create any readers; it merely
      # records data about default values and validation which are then used at
      # initialization time to override the readers provided by OpenStruct
      # itself.
      def setting(name, options = {}, &block)
        options.merge!(block: block)
        @overrides ||= {}
        if @namespace
          # note: we can never have a setting named "_namespace"
          @overrides[@namespace] ||= { _namespace: true }
          @overrides[@namespace][name] = options
        else
          @overrides[name] = options
        end
      end
    end

    namespace :app do
      setting :bind, default: '0.0.0.0'
    end

    setting :default_days, default: 7

    namespace :gerrit do
      setting :host, default: 'localhost'
      setting :port, default: 29418
      setting :user, default: ENV['USER']
    end

    setting :repositories_directory do |name, value|
      raise ArgumentError, "#{name} not set" unless value
      raise ArgumentError, "#{name} not a directory" unless File.directory?(value)
    end

  private

    def initialize(hash = nil)
      super
      deep_open_structify!(self)
      override_methods!(self, self.class.overrides)
    end

    # Recursively replace nested hash values with OpenStructs.
    #
    # This enables us to make nice calls like `Config.foo.bar` instead of
    # the somewhat unsightly `Config.foo[:bar]`.
    def deep_open_structify!(instance)
      # call `to_a` here to avoid mutating the collection during iteration
      instance.each_pair.to_a.each do |key, value|
        if value.is_a?(Hash)
          deep_open_structify!(instance.[]=(key, OpenStruct.new(value)))
        end
      end
    end

    # Recurses through the `overrides` hash, overriding OpenStruct-supplied
    # methods with ones which handle defaults, perform validation, and memoize
    # their results.
    #
    # The `overrides` hash itself is built up using the DSL as this class file
    # is passed. This method is called at runtime, once the YAML file containing
    # the configuration has been loaded from disk.
    def override_methods!(instance, overrides, namespace = nil)
      return unless overrides

      overrides.each do |name, options|
        if options.delete(:_namespace)
          nested = instance.[](name)
          unless nested.is_a?(OpenStruct)
            instance.[]=(name, nested = OpenStruct.new)
          end
          override_methods!(nested, options, name)
        else
          instance.define_singleton_method name do
            value = instance_variable_get("@#{namespace}__#{name}")
            return value if value
            value = instance.[](name) || options[:default]
            options[:block].call(name, value) if options[:block]
            instance_variable_set("@#{namespace}__#{name}", value)
          end
        end
      end
    end
  end
end

require 'ostruct'

module Twigg
  # Simple OpenStruct subclass with some methods overridden in order to provide
  # more detailed feedback in the event of a misconfiguration, or to provide
  # reasonable default values.
  #
  # For example, we override `#repositories_directory` so that we can report to
  # the user that:
  #
  #   - the setting is missing from the configuration file
  #   - the setting does not point at a directory
  #
  # We override `#bind` so that we can supply a reasonable default when the
  # configuration file has no value set.
  class Settings < OpenStruct
    class << self
      # DSL method which creates a reader for the setting `name`. If the
      # configuration file does not contain a value for the setting, return
      # `options[:default]` from the `options` hash.
      def setting(name, options = {})
        define_method name do
          value = instance_variable_get("@#{name}")
          return value if value
          instance_variable_set("@#{name}", self.[](name) || options[:default])
        end
      end
    end

    setting :bind, default: '0.0.0.0'

    def repositories_directory
      @repositories_directory ||= self.[](__method__).tap do |dir|
        raise ArgumentError, "#{__method__} not set" unless dir
        raise ArgumentError, "#{__method__} not a directory" unless File.directory?(dir)
      end
    end
  end
end

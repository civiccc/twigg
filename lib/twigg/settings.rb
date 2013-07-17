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
      #
      # A block maybe provided to do checking of the supplied value prior to
      # returning; for an example, see the `repositories_directory` setting in
      # this file.
      def setting(name, options = {}, &block)
        define_method name do
          value = instance_variable_get("@#{name}")
          return value if value

          value = self.[](name) || options[:default]
          yield name, value if block_given?
          instance_variable_set("@#{name}", value)
        end
      end
    end

    setting :bind,         default: '0.0.0.0'
    setting :default_days, default: 7
    setting :gerrit_host,  default: 'localhost'
    setting :gerrit_port,  default: 29418
    setting :gerrit_user,  default: ENV['USER']

    setting :repositories_directory do |name, value|
      raise ArgumentError, "#{name} not set" unless value
      raise ArgumentError, "#{name} not a directory" unless File.directory?(value)
    end
  end
end

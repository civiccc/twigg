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
  #
  # In order to keep this class a simple and readable manifest of the different
  # options, the real logic is all implemented in the {Twigg::Settings::DSL}
  # module, leaving only the DSL declarations here.
  class Settings < OpenStruct
    autoload :DSL, 'twigg/settings/dsl'
    extend   DSL::ClassMethods
    include  DSL::InstanceMethods

    namespace :app do
      setting :bind,   default: '0.0.0.0'

      namespace :gerrit do
        setting :enabled, default: false
      end
    end

    namespace :cache do
      setting :enabled,   default: false
      setting :expiry,    default: 3600 # 1 hour
      setting :host,      default: 'localhost'
      setting :namespace, default: 'twigg'
      setting :port,      default: 11211
    end

    setting :default_days, default: 7

    namespace :gerrit do
      setting :host, default: 'localhost'
      setting :port, default: 29418
      setting :user, default: ENV['USER']

      namespace :web do
        setting :host,   default: 'https://localhost'
      end

      namespace :db do
        setting :adapter,   default: 'mysql2'
        setting :database,  required: true
        setting :host,      default: 'localhost'
        setting :password
        setting :port,      default: 3306
        setting :user,      default: ENV['USER']
      end
    end

    namespace :github do
      setting :organization, required: true
      setting :token,        required: true
    end

    setting :repositories_directory, required: true do |name, value|
      raise ArgumentError, "#{name} not a directory" unless File.directory?(value)
    end

    setting :teams, default: {} do |name, value|
      if !value.respond_to?(:to_h) || value.to_h.values.any? { |team| !team.is_a?(Array) }
        raise ArgumentError, "#{name} should be a hash of arrays"
      end
    end
  end
end

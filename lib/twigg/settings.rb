require 'ostruct'

module Twigg
  # Simple OpenStruct subclass with some methods overridden in order to provide
  # more detailed feedback in the event of a misconfiguration.
  #
  # For example, we override `#repositories_directory` so that we can report to
  # the user that:
  #
  #   - the setting is missing from the configuration file
  #   - the setting does not point at a directory
  #
  class Settings < OpenStruct
    def repositories_directory
      @repositories_directory ||= self.[](__method__).tap do |dir|
        raise ArgumentError, "#{__method__} not set" unless dir
        raise ArgumentError, "#{__method__} not a directory" unless File.directory?(dir)
      end
    end
  end
end

require 'forwardable'
require 'shellwords'
require 'yaml'

module Twigg
  # The Config class mediates all access to the Twigg config file.
  #
  # First, we look for a YAML file at the location specified by the TWIGGRC
  # environment variable. If that isn't set, we fallback to looking for a config
  # file at `~/.twiggrc`.
  #
  # Example use:
  #
  #   Config.bind                   # the bind address for the Twigg web app
  #                                 # [default: 0.0.0.0]
  #   Config.gerrit.host            # the (optional) Gerrit hostname
  #                                 # [default: localhost]
  #   Config.gerrit.port            # the (optional) Gerrit port
  #                                 # [default: 29418]
  #   Config.gerrit.user            # the (optional) Gerrit username
  #                                 # [default: $USER environment variable]
  #   Config.repositories_directory # where to find repositories
  #
  class Config
    include Console

    class << self
      # For convenience, forward all messages to the underlying {Config}
      # instance. This allows us to write things like `Config.bind` instead of
      # the more verbose `Config.config.bind`.
      extend Forwardable
      def_delegators :config, :method_missing

    private

      # Maintain a "singleton" Config instance for convenient access.
      def config
        @config ||= new
      end
    end

    def initialize
      @settings = Settings.new(config_from_argv ||
                               config_from_env ||
                               config_from_home)
    end

  private

    # Foward all messages to the underlying {Settings} instance.
    def method_missing(method, *args, &block)
      @settings.send(method, *args, &block)
    end

    def config_from_file(path)
      YAML.load_file(path).tap do |contents|
        if File.world_readable?(path)
          warn "#{path} is world-readable"
          stderr strip_heredoc(<<-DOC)

            The Twigg config file may contain sensitive information, such as
            access credentials for external services.

            Suggested action: tighten the filesystem permissions with:

                chmod 600 #{Shellwords.escape path}

          DOC
        end
      end
    end

    def config_from_argv
      # It is a bit of a smell to have the Config class know about argument
      # processing, but, at least in development, Bundler will end up eagerly
      # loading the config when it evaluates the Gemfile (and hence the
      # twigg-app.gemspec), which means that this happens before the
      # Twigg::Command.run method gets a chance to set things up properly.
      path = consume_option(%w[-c --config], ARGV)
      config_from_file(path) if path
    end

    def config_from_env
      config_from_file(ENV['TWIGGRC']) if ENV['TWIGGRC']
    end

    TWIGGRC = '.twiggrc'

    def config_from_home
      config_from_file(File.join(Dir.home, TWIGGRC))
    rescue Errno::ENOENT
      {} # no custom config; assume defaults
    end
  end
end

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
  #   Config.repositories_directory # where to find repositories
  #
  class Config
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
      @settings = Settings.new(config_from_env || config_from_home)
    end

  private

    # Foward all messages to the underlying {Settings} instance.
    def method_missing(method, *args, &block)
      @settings.send(method, *args, &block)
    end

    def config_from_file(path)
      YAML.load_file(path)
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

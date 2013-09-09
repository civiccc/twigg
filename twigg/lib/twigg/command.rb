require 'forwardable'

module Twigg
  class Command
    # Subcommands, in the order they should appear in the help output.
    PUBLIC_SUBCOMMANDS = %w[help init app stats gerrit github pivotal git]

    EASTER_EGGS        = %w[russian]
    SUBCOMMANDS        = PUBLIC_SUBCOMMANDS + EASTER_EGGS

    autoload :Git,     'twigg/command/git'
    autoload :GitHost, 'twigg/command/git_host'
    autoload :GitHub,  'twigg/command/git_hub'
    autoload :Init,    'twigg/command/init'
    autoload :Help,    'twigg/command/help'
    autoload :Russian, 'twigg/command/russian'
    autoload :Stats,   'twigg/command/stats'

    extend Console
    include Console

    class << self
      include Dependency # for with_dependency

      def run(subcommand, *args)
        Help.new('usage').run! unless SUBCOMMANDS.include?(subcommand)

        if args.include?('-h') || args.include?('--help')
          Help.new(subcommand).run
          exit
        end

        begin
          send(subcommand, *args)
        rescue => e
          raise if args.include?('-d') || args.include?('--debug')

          error e.message
          stderr '[run with -d or --debug flag to see full stack trace]'
          die
        end
      end

    private

      def ignore(args)
        if args.any?
          warn "unsupported extra argument#{'s' if args.size > 1} " \
               "#{args.inspect} ignored"
        end
      end

      def app(*args)
        with_dependency('twigg-app') { App.new(*args).run }
      end

      def gerrit(*args)
        with_dependency('twigg-gerrit') { Gerrit.new(*args).run }
      end

      def git(*args)
        Git.new(*args).run
      end

      def github(*args)
        GitHub.new(*args).run
      end

      def help(*args)
        Help.new(*args).run
      end

      def init(*args)
        Init.new(*args).run
      end

      def pivotal(*args)
        with_dependency('twigg-pivotal') { Pivotal.new(*args).run }
      end

      def russian(*args)
        Russian.new(*args).run
      end

      def stats(*args)
        Stats.new(*args).run
      end
    end

    extend Forwardable
    def_delegators 'self.class', :ignore

    def initialize(*args)
      Config.config # ensure `-c`/`--config` option is applied
      consume_option(%w[-c --config], args) # ensure consumed

      @debug   = true if args.delete('-d') || args.delete('--debug')
      @verbose = true if args.delete('-v') || args.delete('--verbose')
      @args    = args
    end

    # Run and then die.
    def run!
      run
      die
    end

    # Abstract implementation of a "run" method; subclasses are expected to
    # override this method.
    def run
      raise NotImplementedError
    end
  end
end

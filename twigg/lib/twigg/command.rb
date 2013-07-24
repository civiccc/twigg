require 'forwardable'

module Twigg
  class Command
    # Subcommands, in the order they should appear in the help output.
    SUBCOMMANDS = %w[help init app stats gerrit github]

    autoload :GitHost, 'twigg/command/git_host'
    autoload :GitHub,  'twigg/command/git_hub'
    autoload :Init,    'twigg/command/init'
    autoload :Help,    'twigg/command/help'
    autoload :Stats,   'twigg/command/stats'

    extend Console
    include Console

    class << self
      def run(subcommand, *args)
        Help.new('usage').run! unless SUBCOMMANDS.include?(subcommand)

        if args.include?('-h') || args.include?('--help')
          Help.new(*args).run
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
        warn "unsupported extra arguments #{args.inspect} ignored" if args.any?
      end

      def with_dependency(gem, &block)
        require gem
        yield
      rescue LoadError => e
        die "#{e}: try `gem install #{gem}`"
      end

      def app(*args)
        ignore args
        with_dependency('twigg-app') { App.run! }
      end

      def gerrit(*args)
        with_dependency('twigg-gerrit') { Gerrit.new(*args).run }
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

      def stats(*args)
        Stats.new(*args).run
      end
    end

    extend Forwardable
    def_delegators 'self.class', :ignore, :with_dependency

    def initialize(*args)
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

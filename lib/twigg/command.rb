module Twigg
  class Command
    # Subcommands, in the order they should appear in the help output.
    SUBCOMMANDS = %w[help app stats gerrit]

    autoload :Gerrit, 'twigg/command/gerrit'
    autoload :Help,   'twigg/command/help'
    autoload :Stats,  'twigg/command/stats'

    def initialize(subcommand, *args)
      Help.new('usage').die unless SUBCOMMANDS.include?(subcommand)

      @debug   = true if args.delete('-d') || args.delete('--debug')
      @verbose = true if args.delete('-v') || args.delete('--verbose')

      if args.include?('-h') || args.include?('--help')
        Help.new(subcommand).die
      end

      @subcommand = subcommand
      @args       = args
    end

    def run
      send(@subcommand, *@args)
    rescue => e
      raise if @debug

      stderr "error: #{e.message}",
        '[run with -d or --debug flag to see full stack trace]'
      exit 1
    end

    def die(msg = nil)
      stderr("error: #{msg}") if msg
      exit 1
    end

  private

    def app(*args)
      ignore args
      App.run!
    end

    def gerrit(*args)
      Gerrit.new(*args)
    end

    def help(topic = nil, *args)
      ignore args
      Help.new(topic)
    end

    def stats(*args)
      Stats.new(*args)
    end

    def stderr(*msgs)
      STDERR.puts(*msgs)
    end

    def warn(msg)
      stderr "warning: #{msg}"
    end

    def ignore(args)
      warn "unsupported extra arguments #{args.inspect} ignored" if args.any?
    end

    def strip_heredoc(doc)
      indent = doc.scan(/^[ \t]*(?=\S)/).map(&:size).min || 0
      doc.gsub(/^[ \t]{#{indent}}/, '')
    end
  end
end

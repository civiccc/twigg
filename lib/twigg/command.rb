module Twigg
  class Command
    # Subcommands, in the order they should appear in the help output.
    SUBCOMMANDS = %w[help app stats]

    autoload :Help,  'twigg/command/help'
    autoload :Stats, 'twigg/command/stats'

    def initialize(subcommand, *args)
      usage unless SUBCOMMANDS.include?(subcommand)

      if args.delete('-v') || args.delete('--verbose')
        @verbose = true
      end

      if args.include?('-h') || args.include?('--help')
        Help.new(subcommand)
        die
      end

      @subcommand = subcommand
      @args       = args
    end

    def run
      send(@subcommand, *@args)
    end

  private

    def app(*args)
      ignore args
      App.run!
    end

    def help(topic = nil, *args)
      ignore args
      Help.new(topic)
    end

    def stats(*args)
      Stats.new(*args)
    end

    def stderr(msg)
      STDERR.puts(msg)
    end

    def warn(msg)
      stderr "warning: #{msg}"
    end

    def die(msg = nil)
      stderr("error: #{msg}") if msg
      exit 1
    end

    def ignore(args)
      warn "unsupported extra arguments #{args.inspect} ignored" if args.any?
    end

    def strip_heredoc(doc)
      indent = doc.scan(/^[ \t]*(?=\S)/).map(&:size).min || 0
      doc.gsub(/^[ \t]{#{indent}}/, '')
    end

    def usage
      stderr strip_heredoc(<<-DOC)
        Usage: #{$0} <subcommand> [options] <arguments...>
               #{$0} help
      DOC
      die
    end
  end
end

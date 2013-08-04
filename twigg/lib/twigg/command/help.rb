require 'shellwords'

module Twigg
  class Command
    class Help < Command
      HELP_TOPICS = SUBCOMMANDS + %w[commands usage]

      def initialize(*args)
        super
        @topic = @args.shift
        ignore @args
      end

      def run
        if HELP_TOPICS.include?(@topic)
          send(@topic)
        else
          HELP_TOPICS.each { |topic| send(topic) }
        end
      end

    private

      def executable
        Shellwords.escape($0)
      end

      def app
        stderr strip_heredoc(<<-DOC)
          Web application:

            #{executable} app

        DOC
      end

      def commands
        stderr strip_heredoc(<<-DOC)
          Commands:

            #{executable} app    # run the Twigg web app
            #{executable} gerrit # clone/update/report from Gerrit
            #{executable} git    # perform operations on Git repos
            #{executable} github # clone/update from GitHub
            #{executable} init   # generate a .twiggrc file
            #{executable} help   # this help information
            #{executable} stats  # show statistics about repos

        DOC
      end

      def gerrit
        stderr strip_heredoc(<<-DOC)
          Gerrit:

            #{executable} gerrit clone [repos dir]  # clone repos into repos dir
            #{executable} gerrit update [repos dir] # update repos in repos dir
            #{executable} gerrit stats [repos dir]  # show stats for repos in dir

        DOC
      end

      def git
        stderr strip_heredoc(<<-DOC)
          Git:

            #{executable} git gc [repos dir] # garbage collect repos in repos dir

        DOC
      end

      def github
        stderr strip_heredoc(<<-DOC)
          GitHub:

            #{executable} github clone [repos dir]  # clone repos into repos dir
            #{executable} github update [repos dir] # update repos in repos dir

        DOC
      end

      def help
        stderr strip_heredoc(<<-DOC)
          Help:

            #{executable} help              # this help information
            #{executable} help <subcommand> # help for a specific subcommand
            #{executable} help commands     # list all subcommands

        DOC
      end

      def init
        stderr strip_heredoc(<<-DOC)
          Init:

            #{executable} init # emit a sample .twiggrc file to standard out

        DOC
      end

      def stats
        stderr strip_heredoc(<<-DOC)
          Stats:

            #{executable} stats [--verbose|-v] <repos dir> <number of days>

        DOC
      end

      def usage
        stderr strip_heredoc(<<-DOC)
          Usage:

            #{executable} <subcommand> [options] <arguments...>
            #{executable} help

        DOC
      end
    end
  end
end

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

      def app
        stderr strip_heredoc(<<-DOC)
          Web application:

            #{$0} app

        DOC
      end

      def commands
        stderr strip_heredoc(<<-DOC)
          Commands:

            #{$0} app    # run the Twigg web app
            #{$0} gerrit # clone/update repos from Gerrit
            #{$0} github # clone/update repos from GitHub
            #{$0} init   # generate a .twiggrc file
            #{$0} help   # this help information
            #{$0} stats  # show statistics about repos

        DOC
      end

      def gerrit
        stderr strip_heredoc(<<-DOC)
          Gerrit:

            #{$0} gerrit clone [repos dir]  # clone repos into repos dir
            #{$0} gerrit update [repos dir] # update repos in repos dir

        DOC
      end

      def github
        stderr strip_heredoc(<<-DOC)
          GitHub:

            #{$0} github clone [repos dir]  # clone repos into repos dir
            #{$0} github update [repos dir] # update repos in repos dir

        DOC
      end

      def help
        stderr strip_heredoc(<<-DOC)
          Help:

            #{$0} help              # this help information
            #{$0} help <subcommand> # help for a specific subcommand
            #{$0} help commands     # list all subcommands

        DOC
      end

      def init
        stderr strip_heredoc(<<-DOC)
          Init:

            #{$0} init # emit a sample .twiggrc file to standard out

        DOC
      end

      def stats
        stderr strip_heredoc(<<-DOC)
          Stats:

            #{$0} stats [--verbose|-v] <repos dir> <number of days>

        DOC
      end

      def usage
        stderr strip_heredoc(<<-DOC)
          Usage:

            #{$0} <subcommand> [options] <arguments...>
            #{$0} help

        DOC
      end
    end
  end
end

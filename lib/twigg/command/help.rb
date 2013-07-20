module Twigg
  class Command
    class Help < Command
      HELP_TOPICS = SUBCOMMANDS + ['commands']

      def initialize(topic)
        if HELP_TOPICS.include?(topic)
          send(topic)
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
            #{$0} init   # generate a .twiggrc file
            #{$0} help   # this help information
            #{$0} stats  # show statistics about repos

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

      def stats
        stderr strip_heredoc(<<-DOC)
          Stats:

            #{$0} stats [--verbose|-v] <repos dir> <number of days>

        DOC
      end
    end
  end
end

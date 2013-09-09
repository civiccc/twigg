module Twigg
  class Command
    class Help < Command
      PUBLIC_HELP_TOPICS = PUBLIC_SUBCOMMANDS + %w[commands usage]
      HELP_TOPICS        = PUBLIC_HELP_TOPICS + EASTER_EGGS

      def initialize(*args)
        super
        @topic = @args.shift
        ignore @args
      end

      def run
        if HELP_TOPICS.include?(@topic)
          show_help(@topic)
        else
          PUBLIC_HELP_TOPICS.each { |topic| show_help(topic) }
        end
      end

    private

      TOPIC_HEADERS = Hash.new { |h, k| h[k] = k.capitalize }.merge(
        # header = subcommand with first letter capitalized; exceptions:
        'app'    => 'Web application',
        'github' => 'GitHub',
      )

      def show_help(topic)
        puts TOPIC_HEADERS[topic] + ':'
        stderr strip_heredoc(send(topic), indent: 2) + "\n"
      end

      def app
        <<-DOC
          twigg app [-D|--daemon] [-P|--pidfile <pidfile>]
        DOC
      end

      def commands
        <<-DOC
          twigg app     # run the Twigg web app
          twigg gerrit  # clone/update/report from Gerrit
          twigg git     # perform operations on Git repos
          twigg github  # clone/update from GitHub
          twigg init    # generate a .twiggrc file
          twigg help    # this help information
          twigg pivotal # show open stories in Pivotal Tracker
          twigg stats   # show statistics about repos
        DOC
      end

      def gerrit
        <<-DOC
          twigg gerrit clone [repos dir]  # clone repos into repos dir
          twigg gerrit update [repos dir] # update repos in repos dir
          twigg gerrit stats [repos dir]  # show stats for repos in dir
        DOC
      end

      def git
        <<-DOC
          twigg git gc [repos dir] # garbage collect repos in repos dir
        DOC
      end

      def github
        <<-DOC
          twigg github clone [repos dir]  # clone repos into repos dir
          twigg github update [repos dir] # update repos in repos dir
        DOC
      end

      def help
        <<-DOC
          twigg help              # this help information
          twigg help <subcommand> # help for a specific subcommand
          twigg help commands     # list all subcommands
        DOC
      end

      def init
        <<-DOC
          twigg init # emit a sample .twiggrc file to standard out
        DOC
      end

      def pivotal
        <<-DOC
          twigg pivotal stats # show overview of open stories
        DOC
      end

      def russian
        <<-DOC
          twigg russian <repos dir> <number of days> # easter egg
        DOC
      end

      def stats
        <<-DOC
          twigg stats [--verbose|-v] <repos dir> <number of days>
        DOC
      end

      def usage
        <<-DOC
          twigg <subcommand> [options] <arguments...>
          twigg help
        DOC
      end
    end
  end
end

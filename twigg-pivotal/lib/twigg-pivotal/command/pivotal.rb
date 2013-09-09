module Twigg
  class Command
    class Pivotal < Command
      include Util
      SUB_SUBCOMMANDS = ['stats']

      def initialize(*args)
        super
        @sub_subcommand = @args.shift
        ignore @args

        unless SUB_SUBCOMMANDS.include?(@sub_subcommand)
          Help.new('pivotal').run!
        end
      end

      def run
        send @sub_subcommand
      end

    private

      # Shows a list of open stories, grouped by status.
      def stats
        groups = ::Twigg::Pivotal::Status.status

        groups.each do |current_state, stories|
          header = pluralize stories.size,
                             "#{current_state} story",
                             "#{current_state} stories"
          puts header

          stories.each do |story|
            print "[#{story.story_type}] #{story.name}"
            if story.owned_by
              puts " [#{story.owned_by['initials']}]"
            else
              puts
            end
          end

          puts
        end

        puts '', 'Totals'
        groups.each do |current_state, stories|
          puts number_with_delimiter(stories.size) + " #{current_state}"
        end
        puts
      end
    end
  end
end

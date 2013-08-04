module Twigg
  class Command
    class Git < GitHost
    private

      def sub_subcommands
        %w[gc]
      end

      def projects
        @projects ||= RepoSet.new(@repositories_directory).repos.map(&:name)
      end

      def gc
        for_each_repo do |project|
          Dir.chdir project do
            git 'gc', '--quiet'
          end
        end
      end
    end
  end
end

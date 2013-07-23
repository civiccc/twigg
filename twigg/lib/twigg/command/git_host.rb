module Twigg
  class Command
    # This is an abstract superclass the holds code common to the "gerrit" and
    # "github" subcommands.
    class GitHost < Command
      SUB_SUBCOMMANDS = %w[clone update]

      def initialize(*args)
        super
        @sub_subcommand = @args.first

        unless (1..2).cover?(@args.size) &&
          SUB_SUBCOMMANDS.include?(@sub_subcommand)
          # eg. "Twigg::Command::{Gerrit,GitHub}" -> "gerrit/github"
          Help.new(self.class.to_s.split('::').last.downcase).run!
        end

        @repositories_directory = @args[1] || Config.repositories_directory
      end

      def run
        send @sub_subcommand
      end

    private

      def for_each_repo(&block)
        Dir.chdir @repositories_directory do
          projects.each do |project|
            print @verbose ? "#{project}: " : '.'
            block.call(project)
            puts ' done' if @verbose
          end
          puts
        end
      end

      def clone
        for_each_repo do |project|
          if File.directory?(project)
            print 'skipping (already present);' if @verbose
          else
            print 'cloning...' if @verbose
            git_clone(project)
          end
        end
      end

      def update
        for_each_repo do |project|
          if File.directory?(project)
            Dir.chdir project do
              print 'pulling...' if @verbose
              git_pull
            end
          else
            print 'skipping (not present);' if @verbose
          end
        end
      end

      # Convenience method for running a Git command that is expected to succeed
      # (raises an error if a non-zero exit code is produced).
      def git(*args)
        Process.wait(IO.popen(%w[git] + args).pid)
        raise unless $?.success?
      end

      # Runs `git clone` to obtain the specified `project`.
      def git_clone(project)
        git 'clone', '--quiet', address(project)
      end

      # Runs `git fetch --quiet` followed by `git merge --ff-only --quiet
      # FETCH_HEAD`.
      #
      # We do this as two commands rather than a `git pull` because the latter
      # is much fussier about tracking information being in place.
      def git_pull
        git 'fetch', '--quiet'
        git 'merge', '--ff-only', '--quiet', 'FETCH_HEAD'
      rescue => e
        # could die here if remote doesn't contain any commits yet
      end

      def address(*args)
        raise NotImplementedError # subclass responsibility
      end

      # Returns the list of all projects hosted within a Git host.
      def projects
        raise NotImplementedError # subclass responsibility
      end
    end
  end
end

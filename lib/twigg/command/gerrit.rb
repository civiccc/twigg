module Twigg
  class Command
    # The "gerrit" subcommand can be used to conveniently initialize a set of
    # repos and keep them up-to-date.
    class Gerrit < Command
      def initialize(*args)
        if args.size > 1
          Help.new('gerrit')
          die
        end

        @repositories_directory = args.first || Config.repositories_directory

        run
      end

    private

      def run
        Dir.chdir @repositories_directory do
          projects.each do |project|
            print @verbose ? "#{project}: " : '.'

            if File.directory?(project)
              Dir.chdir project do
                print 'pulling...' if @verbose
                pull
              end
            else
              print 'cloning...' if @verbose
              clone(project)
            end
            puts ' done' if @verbose

          end
          puts
        end
      end

      # Convenience method for running a Git command that is expected to succeed
      # (raises an error if a non-zero exit code is produced).
      def git(*args)
        Process.wait(IO.popen(%w[git] + args).pid)
        raise unless $?.success?
      end

      # Runs `git clone` to obtain the specified `project`.
      def clone(project)
        git 'clone', '--quiet', address(project)
      end

      # Runs `git fetch --quiet` followed by `git merge --ff-only --quiet
      # FETCH_HEAD`.
      #
      # We do this as two commands rather than a `git pull` because the latter
      # is much fussier about tracking information being in place.
      def pull
        git 'fetch', '--quiet'
        git 'merge', '--ff-only', '--quiet', 'FETCH_HEAD'
      rescue => e
        # could die here if remote doesn't contain any commits yet
      end

      # Returns a Gerrit address.
      #
      # Examples:
      #
      #   address('foo')
      #   => ssh://jimmy@gerrit.example.com:29418/foo.git
      #   address(port: false, protocol: false)
      #   => jimmy@gerrit.example.com
      #
      def address(project = nil, port: true, protocol: true)
        [].tap do |address|
          address << 'ssh://' if protocol
          address << "#{Config.gerrit.user}@#{Config.gerrit.host}"
          address << ":#{Config.gerrit.port}" if port
          address << "/#{project}.git" if project
        end.join
      end

      # Returns the list of all projects hosted within a Gerrit instance.
      def projects
        @projects ||= begin
          port         = Config.gerrit.port.to_s
          user_at_host = address(port: false, protocol: false)
          command      = ['ssh', '-p', port, user_at_host, 'gerrit', 'ls-projects']

          # Don't bother redirecting stderr; let it slip through to the user,
          # where it may provide useful feedback (such as "Permission denied
          # (publickey)." or similar).
          IO.popen(command, 'r') { |io| io.read }.split.tap do
            die 'failed to retrieve project list' unless $?.success?
          end
        end
      end
    end
  end
end

module Twigg
  class Command
    # The "gerrit" subcommand can be used to conveniently initialize a set of
    # repos and keep them up-to-date.
    class Gerrit < GitHost
    private

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

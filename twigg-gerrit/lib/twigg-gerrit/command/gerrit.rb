module Twigg
  class Command
    # The "gerrit" subcommand can be used to conveniently initialize a set of
    # repos and keep them up-to-date.
    class Gerrit < GitHost
      include Util

    private

      def sub_subcommands
        super + ['stats']
      end

      def db
        @db ||= begin
          require 'sequel'

          adapter = Config.gerrit.db.adapter # eg. mysql2
          with_dependency(adapter) do
            db = Sequel.send(adapter, Config.gerrit.db.database,
                            host:     Config.gerrit.db.host,
                            password: Config.gerrit.db.password,
                            port:     Config.gerrit.db.port,
                            user:     Config.gerrit.db.user)
          end
        end
      end

      # Shows a list of open changes, ordered by last update date (descending).
      def stats
        changes = db[:changes].
          select(:change_id, :last_updated_on, :subject, :full_name).
          join(:accounts, account_id: :owner_account_id).
          where(status: 'n').
          order(Sequel.desc(:last_updated_on)).all

        puts "Open changes (#{changes.count})"
        changes.map do |change|
          puts "  #%-6d %s [%s] %s" % [
            change[:change_id],
            change[:subject],
            change[:full_name],
            age(change[:last_updated_on]),
          ]
        end
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

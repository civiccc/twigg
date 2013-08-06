require 'forwardable'
require 'sequel'

module Twigg
  module Gerrit
    class DB
      include Dependency # for with_dependency

      class << self
        extend Forwardable
        def_delegators :db, :[]

      private

        def db
          @db ||= new
          @db.db
        end
      end

      def db
        @db ||= begin
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
    end
  end
end

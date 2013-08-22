require 'dalli'
require 'forwardable'

module Twigg
  module Cache
    class Client
      extend Forwardable
      def_delegators '@client', :get, :set

      def initialize
        @client = Dalli::Client.new("#{Config.cache.host}:#{Config.cache.port}",
                                    compress:   true,
                                    expires_in: Config.cache.expiry,
                                    namespace:  Config.cache.namespace)
      end
    end
  end
end

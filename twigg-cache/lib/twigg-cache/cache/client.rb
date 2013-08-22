require 'dalli'
require 'forwardable'

module Twigg
  module Cache
    class Client
      extend Forwardable
      def_delegators '@client', :get, :set

      def initialize
        options = {
          compress:        true,
          expires_in:      Config.cache.expiry,
          value_max_bytes: Config.cache.value_max_bytes,
          namespace:       Config.cache.namespace,
        }.delete_if { |key, value| value.nil? }

        @client = Dalli::Client.new("#{Config.cache.host}:#{Config.cache.port}",
                                    options)
      end
    end
  end
end

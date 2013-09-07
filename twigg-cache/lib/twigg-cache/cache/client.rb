require 'dalli'

module Twigg
  module Cache
    class Client
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

      def get(key)
        @client.get(key)
      rescue Dalli::RingError
        # degrade gracefully
      end

      def set(key, value)
        @client.set(key, value)
      rescue Dalli::RingError
        # degrade gracefully
      end
    end
  end
end

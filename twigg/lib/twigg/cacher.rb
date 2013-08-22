module Twigg
  # The Cacher module is an abstraction around caching that offers two public
  # methods, {Twigg::Cacher.get} and {Twigg::Cacher.set}.
  #
  # If the twigg-cache gem is installed and enabled, delegates the storing of
  # cached items to Memcached. In the absence of the gem, every cache lookup is
  # treated as a miss.
  module Cacher
    # Dummy Memcached client that always misses.
    class DummyClient
      def get(key); end
      def set(key); end
    end

    class << self
      include Dependency # for with_dependency

      # Gets stored value for `key`; in the event of a cache miss, yields to
      # `block`, and caches and returns the result.
      #
      # Note: if a `nil` or `false` value is ever stored in the cache, this
      # method will consider any lookup of the corresponding key to be a miss,
      # because we employ a simply truthiness check to determine presence.
      def get(key, &block)
        raise ArgumentError, 'block required by not given' unless block_given?
        client.get(key) || set(key, &block)
      end

      # Stores the result of yielding to `block` in the cache, with `key` as
      # key, and returns the result.
      def set(key, &block)
        yield.tap { |result| client.set(key, result) }
      end

    private

      def client
        @client ||= (caching? ? Cache::Client.new : DummyClient.new)
      end

      def caching?
        return false unless Config.cache.enabled # don't want to load the gem
        return true if defined?(Twigg::Cache)    # gem was already loaded
        with_dependency('twigg-cache') { true }  # will die if can't load
      end
    end
  end
end

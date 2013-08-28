require 'digest/sha1'

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
      # `block`, and caches and returns the result. `*args`, if present, are
      # hashed and appended to key to permit the results of different calls to
      # the same method to be conveniently stored and retrieved independently.
      #
      # Note: if a `nil` or `false` value is ever stored in the cache, this
      # method will consider any lookup of the corresponding key to be a miss,
      # because we employ a simple truthiness check to determine presence.
      def get(key, *args, &block)
        raise ArgumentError, 'block required by not given' unless block_given?
        digest = hashed_key_and_args(key, *args)
        client.get(digest) || set(key, *args, &block)
      end

      # Stores the result of yielding to `block` in the cache, with `key` as
      # key, and returns the result.
      #
      # As with {get}, any `*args`, if present, are hashed and appended to the
      # key to premit the results of different calls to the same method to be
      # conveniently stored and retrieved independently.
      def set(key, *args, &block)
        digest = hashed_key_and_args(key, *args)
        yield.tap { |result| client.set(digest, result) }
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

      # Produces a composite cache key based on `key` and a digest of `args`.
      #
      # If `args` contains non-shallow objects such as hashes or arrays, uses
      # recursion to incorporate the contents of those objects in the digest.
      #
      # Will raise an exception if `args` or any object encontered via recursion
      # is not a "simple" object (Hash, Array, String, NilClas, Numeric, or
      # Symbol).
      def hashed_key_and_args(key, *args)
        base = args.inject('') do |memo, arg|
          memo << (':' + arg.class.to_s + ':') << case arg
          when Array
            hashed_key_and_args(key, *arg)
          when Hash
            hashed_key_and_args(key, *arg.to_a)
          when NilClass,Numeric, String, Symbol
            arg.to_s
          else
            raise ArgumentError, 'can only compute digest for primitive objects'
          end

          Digest::SHA1::hexdigest(memo)
        end

        key + ':' + base
      end
    end
  end
end

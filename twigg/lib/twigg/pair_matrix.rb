require 'forwardable'

module Twigg
  class PairMatrix
    extend Forwardable
    def_delegators :pairs, :[], :keys

    def initialize(commit_set)
      @commit_set = commit_set
    end

    def pairs
      @pairs ||= Hash.new do |hash, pairer|
        hash[pairer] = Hash.new { |hash, pairee| hash[pairee] = 0 }
      end.tap do |matrix|
        @commit_set.each do |commit|
          authors = commit.author_names

          # if you're solo, that's equivalent to pairing with yourself
          authors *= 2 if authors.size == 1

          authors.permutation(2).each do |pairer, pairee|
            matrix[pairer][pairee] += 1
          end
        end
      end
    end

    def authors
      @authors ||= pairs.keys.sort
    end

    def max_solo
      @max_solo ||= pairs.inject(0) do |max, (pairee, pairs)|
        [pairs.inject(0) do |max, (pairer, count)|
          [pairee == pairer ? count : 0, max].max
        end, max].max
      end
    end

    def max_pair
      @max_pair ||= pairs.inject(0) do |max, (pairee, pairs)|
        [pairs.inject(0) do |max, (pairer, count)|
          [pairee == pairer ? 0 : count, max].max
        end, max].max
      end
    end
  end
end

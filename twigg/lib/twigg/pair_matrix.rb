require 'forwardable'

module Twigg
  # A PairMatrix is initialized with a {CommitSet} instance and computes
  # pairing information for those commits.
  class PairMatrix
    extend Forwardable
    def_delegators :pairs, :[], :keys

    def initialize(commit_set)
      @commit_set = commit_set
    end

    # Returns a sparse matrix representing the pairing permutations, and commit
    # counts for each, in the receiver.
    #
    # The returned matrix is a Hash data structure and can be queried like so:
    #
    #     pm['Joe Lencioni']['Noah Silas']   #=> 3 (commit count by the pair)
    #     pm['Tony Wooster']['Tony Wooster'] #=> 9 (commit count as solo author)
    #     pm['Joe Lencioni']['Tony Wooster'] #=> 0 (no commits, no pairing)
    #
    # Note that the {#[]} method is forwarded to the underlying Hash, which
    # means that the above examples work equally well whether `pm` is an
    # instance of a {PairMatrix} or the result of a call to the the {#pairs}
    # method on a {PairMatrix} instance.
    def pairs
      @pairs ||= sparse_matrix.tap do |matrix|
        @commit_set.each do |commit|
          authors = commit.author_names

          # if you're solo, that's equivalent to pairing with yourself
          authors *= 2 if authors.size == 1

          authors.permutation(2).to_a.uniq.each do |pairer, pairee|
            matrix[pairer][pairee] += 1
          end
        end
      end
    end

    # Returns a sorted array of names corresponding to the authors represented
    # in the matrix.
    def authors
      @authors ||= pairs.keys.sort
    end

    # Scan the matrix, identifying and returning the "solo" element (ie. one
    # person working alone) with the highest number of commits.
    def max_solo
      @max_solo ||= pairs.inject(0) do |max, (pairee, pairs)|
        [pairs.inject(0) do |max, (pairer, count)|
          [pairee == pairer ? count : 0, max].max
        end, max].max
      end
    end

    # Scan the matrix, identifying and returning the "pair" element (ie. two
    # distinct people pairing) with the highest number of commits.
    def max_pair
      @max_pair ||= pairs.inject(0) do |max, (pairee, pairs)|
        [pairs.inject(0) do |max, (pairer, count)|
          [pairee == pairer ? 0 : count, max].max
        end, max].max
      end
    end

  private

    # Returns a Hash instance that models a sparse matrix.
    #
    # Looking up a pairee/pairer pair in the matrix returns 0 if the matrix does
    # not have a value for that entry; for example:
    #
    #     sparse_matrix['Jimmy Kittiyachavalit']['Chris Chan'] #=> 0
    #
    def sparse_matrix
      Hash.new do |hash, pairer|
        hash[pairer] = Hash.new { |hash, pairee| hash[pairee] = 0 }
      end
    end
  end
end

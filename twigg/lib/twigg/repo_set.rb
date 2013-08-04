require 'pathname'

module Twigg
  # Represents a set of Git repositories existing in a directory.
  class RepoSet
    def initialize(repositories_directory)
      @repositories_directory = Pathname.new(repositories_directory)
    end

    # Execute `block` for each repo in the set.
    #
    # The {Repo} object is passed in to the block.
    def for_each_repo(&block)
      repos.each do |repo|
        block.call(repo)
      end
    end

  private

    def repos
      @repos ||= begin
        Dir[File.join(@repositories_directory, '*')].map do |path|
          begin
            repo = Repo.new(path)
          rescue Repo::InvalidRepoError
            # most likely an empty or non-Git directory
          end
        end.compact
      end
    end
  end
end

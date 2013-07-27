module Twigg
  module Gatherer
    def self.gather(repositories_directory, days)
      since = Time.now - days * 24 * 60 * 60

      CommitSet.new.tap do |commit_set|
        Dir[File.join(repositories_directory, '*')].each do |repo_path|
          begin
            Repo.new(repo_path).commits(since: since).each do |commit|
              commit_set << commit
            end
          rescue Repo::InvalidRepoError
            # most likely an empty or non-Git directory
          end
        end
      end
    end
  end
end

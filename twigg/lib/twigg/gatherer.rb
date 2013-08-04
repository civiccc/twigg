module Twigg
  module Gatherer
    def self.gather(repositories_directory, days)
      since = Time.now - days * 24 * 60 * 60

      CommitSet.new.tap do |commit_set|
        RepoSet.new(repositories_directory).for_each_repo do |repo|
          repo.commits(since: since).each do |commit|
            commit_set << commit
          end
        end
      end
    end
  end
end

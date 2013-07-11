module Twig
  module Gatherer
    def self.gather(repositories_directory, days_ago)
      since = Time.now - days_ago * 24 * 60 * 60

      commit_set = CommitSet.new
      Dir[File.join(repositories_directory, '*')].each do |repo_path|
        Repo.new(repo_path).commits(all: true, since: since).each do |commit|
          commit_set.add_commit(commit)
        end
      end
      commit_set
    end
  end
end

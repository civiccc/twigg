module Quant
  class Commit
    def initialize(repo, commit)
      @repo = repo
      @commit = commit
    end

    def repo_name
      @repo.workdir.split('/').last
    end

    def author_email
      @commit.author[:email]
    end

    def author_names
      @commit.author[:name].split(/\+|&|,|\band\b/).map(&:strip)
    end

    def date
      Time.at(@commit.time).to_date
    end
  end

  class CommitSet
    def initialize(commits = nil)
      @commits = commits ? commits.dup : []
    end

    def count
      @commits.count
    end

    def count_by_day(days_ago)
      start_date = Date.today - days_ago
      end_date = Date.today
      date_to_commits = @commits.group_by { |commit| commit.date }
      (start_date..end_date).map do |date|
        { date: date, count: date_to_commits.fetch(date, []).count }
      end
    end

    def add_commit(commit)
      @commits << commit
    end

    def count_by_repo
      counts = Hash.new(0)
      @commits.each { |commit| counts[commit.repo_name] += 1 }
      counts.sort_by { |repo_name, count| -count }.
        map { |repo_name, count| { repo_name: repo_name, count: count } }
    end

    def select_author(author)
      commits_for_author = @commits.select do |commit|
        commit.author_names.include?(author)
      end
      self.class.new(commits_for_author)
    end

    def top_authors
      author_to_commit_set = Hash.new{ |h, k| h[k] = self.class.new }
      @commits.each do |commit|
        commit.author_names.each do |author_name|
          author_to_commit_set[author_name].add_commit(commit)
        end
      end

      author_to_commit_set.
        sort_by { |author, commit_set| -commit_set.count }.
        map { |author, commit_set| { author: author, commit_set: commit_set } }
    end
  end

  module Gatherer
    def self.gather(repositories_directory, days_ago)
      since = Time.now - days_ago * 24 * 60 * 60

      commit_set = CommitSet.new
      Dir[File.join(repositories_directory, '*')].each do |repo_path|
        begin
          repo = Rugged::Repository.new(repo_path)
          walker = Rugged::Walker.new(repo)
          walker.sorting(Rugged::SORT_DATE)
          walker.push(repo.head.target)
          walker.each do |rugged_commit|
            break if rugged_commit.time < since.to_i
            commit_set.add_commit(Commit.new(repo, rugged_commit))
          end
        rescue StandardError => e
          $stderr.puts repo_path
          $stderr.puts e.message
        end
      end
      commit_set
    end
  end
end

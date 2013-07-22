module Twigg
  class CommitSet
    attr_reader :commits

    def initialize(commits = nil)
      @commits = commits ? commits.dup : []
    end

    def count
      @commits.count
    end

    def count_by_day(days)
      start_date = Date.today - days
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
      @commits.each { |commit| counts[commit.repo.name] += 1 }
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
      author_to_commit_set = Hash.new { |h, k| h[k] = self.class.new }
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
end

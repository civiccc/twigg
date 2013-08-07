require 'forwardable'
require 'set'

module Twigg
  class CommitSet
    extend Forwardable
    def_delegators :commits, :any?, :count, :each, :<<
    attr_reader :commits

    def initialize(commits = [])
      @commits = commits
    end

    def additions
      commits.inject(0) { |memo, commit| memo + commit.stat[:additions] }
    end

    def deletions
      commits.inject(0) { |memo, commit| memo + commit.stat[:deletions] }
    end

    def count_by_day(days)
      start_date = Date.today - days
      end_date = Date.today
      date_to_commits = @commits.group_by { |commit| commit.date }
      (start_date..end_date).map do |date|
        { date: date, count: date_to_commits.fetch(date, []).count }
      end
    end

    # Returns a copy of the receiver merged with `commit_set`.
    def +(commit_set)
      unless commit_set.is_a?(CommitSet)
        raise TypeError, "expected Twigg::CommitSet, got #{commit_set.class}"
      end

      dup.tap do |other|
        other.commits.concat(commit_set.commits)
        other.commits.uniq!
      end
    end

    def count_by_repo
      counts = Hash.new(0)
      each { |commit| counts[commit.repo] += 1 }
      counts.sort_by { |repo, count| -count }.
        map { |repo, count| { repo: repo, count: count } }
    end

    def select_author(author)
      commits_for_author = @commits.select do |commit|
        commit.author_names.include?(author)
      end

      self.class.new(commits_for_author)
    end

    def select_team(team)
      members = Set.new(Config.teams[team])

      commits_for_team = @commits.select do |commit|
        commit.author_names.any? { |author| members.include?(author) }
      end

      self.class.new(commits_for_team)
    end

    def authors
      author_to_commit_set.
        sort_by { |author, commit_set| -commit_set.count }.
        map { |author, commit_set| { author: author, commit_set: commit_set } }
    end

    # Returns a sparse pairing "matrix".
    #
    # Keys are pairer names. Values are hashes of pairees-to-count maps.
    def pairs
      PairMatrix.new(self)
    end

    def teams
      set = author_to_commit_set

      teams = Config.teams.each_pair.map do |team, members|
        commits = members.each_with_object(self.class.new) do |member, commit_set|
          if member = set.delete(member)
            commit_set += member
          end
        end

        if commits.any?
          {
            author:     team.to_s,
            commit_set: commits,
            authors:    members,
          }
        end
      end.compact.sort_by { |team| -team[:commit_set].count }

      unless set.empty?
        teams << {
          author:     'Other',
          commit_set: set.values.inject(self.class.new, :+),
          authors:    set.keys,
        }
      end

      teams
    end

  private

    def author_to_commit_set
      Hash.new { |h, k| h[k] = self.class.new }.tap do |set|
        each do |commit|
          commit.author_names.each { |author_name| set[author_name] << commit }
        end
      end
    end
  end
end

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
  end

  class Person
    attr_reader :name

    def initialize(name)
      @name = name
      @commits = []
    end

    def commit_count
      @commits.size
    end

    def add_commit(commit)
      @commits << commit
    end

    def scorecard
      counts = Hash.new(0)
      @commits.each { |commit| counts[commit.repo_name] += 1 }
      counts.sort_by { |repo_name, count| -count }.
        map { |repo_name, count| "#{repo_name}:#{count}" }.
        join(', ')
    end
  end

  class CommitStats
    attr_reader :commits

    def initialize(repo_paths, since)
      @commits = []
      @people_by_name = Hash.new{ |h, k| h[k] = Person.new(k) }

      repo_paths.each do |repo_path|
        begin
          repo = Rugged::Repository.new(repo_path)
          walker = Rugged::Walker.new(repo)
          walker.sorting(Rugged::SORT_DATE)
          walker.push(repo.head.target)
          walker.each do |commit|
            break if commit.time < since.to_i
            @commits << Commit.new(repo, commit)
          end
        rescue StandardError => e
          $stderr.puts repo_path
          $stderr.puts e.message
        end
      end

      @commits.each do |commit|
        next if commit.author_email !~ /@causes\.com$/
        commit.author_names.each do |author_name|
          @people_by_name[author_name].add_commit(commit)
        end
      end
    end

    def people_by_most_commits
      @people_by_name.values.sort_by(&:commit_count).reverse
    end
  end
end

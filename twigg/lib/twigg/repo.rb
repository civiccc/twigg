require 'date'
require 'pathname'

module Twigg
  # Abstraction around a Git repository on disk.
  class Repo
    class InvalidRepoError < RuntimeError; end

    # Given `path` to a Git repository on disk sets up a `Repo` instance.
    #
    # Raises an {InvalidRepoError} if `path` does not point to the top level of
    # an existent Git repo.
    def initialize(path)
      @path = Pathname.new(path)
      raise InvalidRepoError unless valid?
    end

    # Returns an array of {Commit} objects reachable from the HEAD of the repo.
    #
    # There are a number of keyword arguments that correspond to the options of
    # the same name to `git log`:
    #
    #   - `all:` : return reachable commits from all branches, not just HEAD
    #   - `since:`: only return commits made since this Time
    #
    def commits(all: true, since: nil)
      args = []
      args << '--all' if all
      args << "--since=#{since.to_i}" if since
      @commits ||= {}
      @commits[args] ||= parse_log(log(*args))
    end

    # Returns the name of the repo.
    #
    # The name is inferred from the final component of the repo path.
    def name
      @path.basename.to_s
    end

    def link
      if Config.github.organization
        "https://github.com/#{Config.github.organization}/#{name}"
      end
    end

  private

    STDERR_TO_STDOUT = [err: [:child, :out]]

    def git_dir
      @git_dir ||= begin
        # first try repo "foo" (bare repo), then "foo/.git" (non-bare repo)
        [@path, @path + '.git'].map(&:to_s).find do |path|
          Process.wait(
            IO.popen({ 'GIT_DIR' => path },
                     %w[git rev-parse --git-dir] + STDERR_TO_STDOUT).pid
          )
          $?.success?
        end
      end
    end

    # Check to see if this is a valid repo:
    #
    #   - the repo path should exist
    #   - the path should point to the top level of the repo
    #   - the check should work for both bare and non-bare repos
    #
    # Delegates to `#git_dir`
    alias :valid? :git_dir

    def git(command, *args)
      # send both stderr and stdout to stdout
      IO.popen([{ 'GIT_DIR' => git_dir },
                'git', command, *args, *STDERR_TO_STDOUT], 'r') do |io|
        io.read
      end
    end

    def log(*args)
      git 'log', '--numstat', '--format=raw', *args
    end

    def parse_log(string)
      [].tap do |commits|
        tokens = string.scan %r{
          ^commit\s+([a-f0-9]{40})$ |                   # digest
          ^author\s+(.*?)\s+<(.+)>\s\d+\s[+-]\d{4,6}$ | # author (name, email)
          ^committer\s+.+\s+<.+>\s(\d+)\s[+-]\d{4,6}$ | # committer (date)
          ^[ ]{4}(.+?)$ |                               # subject + message
          ^(\d+)\t(\d+)\t.+$                            # num stats (per file)
        }x

        while token = tokens.shift
          commit  = token[0]
          author  = tokens.shift
          author  = author[1].size > 0 ? author[1] : author[2] # name -> email
          date    = Time.at(tokens.shift[3].to_i).to_date
          subject = tokens.first && tokens.first[4] || ''      # --allow-empty-message
          tokens.shift while tokens.first && tokens.first[4]   # commit message body, drop

          # stats can be blank if --allow-empty or a merge commit
          stat = Hash.new(0)
          while tokens.first && tokens.first[5] && token = tokens.shift
            stat[:additions] += token[5].to_i
            stat[:deletions] += token[6].to_i
          end

          commits << Commit.new(repo:    self,
                                commit:  commit,
                                subject: subject,
                                author:  author,
                                date:    date,
                                stat:    stat)
        end
      end
    end
  end
end

require 'date'
require 'pathname'

module Twig
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
    # There are a number of options that correspond to the options of the same
    # name to `git log`:
    #
    #   - `since:`: only return commits made since this Time
    #   - `all:` : return reachable commits from all branches, not just HEAD
    #
    def commits(options = {})
      args = []
      args << '--all' if options[:all]
      args << "--since=#{options[:since].to_i}" if options[:since]
      @commits ||= {}
      @commits[options] ||= parse_log(log(*args))
    end

    # Returns the name of the repo.
    #
    # The name is inferred from the final component of the repo path.
    def name
      @path.basename.to_s
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
          ^commit\s+([a-f0-9]{40})$ |                  # digest
          ^author\s+(.+)\s+<.+>\s\d+\s[+-]\d{4}$ |     # author (name)
          ^committer\s+.+\s+<.+>\s(\d+)\s[+-]\d{4}$ |  # committer (date)
          ^[ ]{4}(.+?)$ |                              # subject + message
          ^(\d+)\t(\d+)\t.+$                           # num stats (per file)
        }x

        while token = tokens.shift
          commit  = token[0]
          author  = tokens.shift[1]
          date    = Time.at(tokens.shift[2].to_i).to_date
          subject = tokens.shift[3]
          tokens.shift while tokens.first && tokens.first[3] # commit message body, drop

          stat = Hash.new(0)
          while tokens.first && tokens.first[4] && token = tokens.shift
            stat[:additions] += token[4].to_i
            stat[:deletions] += token[5].to_i
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

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
      @commits[args] ||= log(*args, method('parse_log'))
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

    # Runs the Git command, `command`, with args `args`.
    #
    # Yields an IO object to the passed-in block that can be used to read the
    # output (for example, with `#each_line`).
    def git(command, *args)
      block = args.pop
      IO.popen([{ 'GIT_DIR' => git_dir },
                'git', command, *args, *STDERR_TO_STDOUT], 'r') do |io|
        block.call(io)
      end
    end

    def log(*args, &block)
      format = [
        '%H',  # commit hash
        '%n',  # newline
        '%aN', # author name (respecting .mailmap)
        '%n',  # newline
        '%ct', # committer date, UNIX timestamp
        '%n',  # newline
        '%s',  # subject
      ].join
      git 'log', "--pretty=format:'#{format}'", '--numstat', *args, &block
    end

    def parse_log(io)
      [].tap do |commits|
        lines = io.each_line
        loop do
          begin
            commit           = { commit: lines.next.chomp }
            commit[:author]  = lines.next.chomp
            commit[:date]    = Time.at(lines.next.chomp.to_i).to_date
            commit[:subject] = lines.next.chomp
            commit[:stat]    = Hash.new(0)
            commit[:repo]    = self

            while lines.peek =~ /^(\d+|-)\t(\d+|-)\t.+$/ && lines.next
              commit[:stat][:additions] += $~[1].to_i
              commit[:stat][:deletions] += $~[2].to_i
            end
            lines.next if lines.peek == "\n" # blank separator line

          rescue StopIteration
            break # end of output
          ensure
            # if the underlying repo is bad (eg. no commits yet) this could
            # raise an ArgumentError, so we rescue
            commit = Commit.new(commit) rescue nil
            commits << commit if commit
          end
        end
      end
    end
  end
end

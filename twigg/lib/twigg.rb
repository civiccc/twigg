require 'pathname'

module Twigg
  autoload :Command,    'twigg/command'
  autoload :Commit,     'twigg/commit'
  autoload :CommitSet,  'twigg/commit_set'
  autoload :Config,     'twigg/config'
  autoload :Console,    'twigg/console'
  autoload :Dependency, 'twigg/dependency'
  autoload :Gatherer,   'twigg/gatherer'
  autoload :PairMatrix, 'twigg/pair_matrix'
  autoload :Repo,       'twigg/repo'
  autoload :RepoSet,    'twigg/repo_set'
  autoload :Settings,   'twigg/settings'
  autoload :Team,       'twigg/team'
  autoload :Util,       'twigg/util'
  autoload :VERSION,    'twigg/version'

  # Returns a Pathname instance corresponding to the root directory of the gem
  # (ie. the directory containing the `files` and `templates` directories).
  def self.root
    Pathname.new(__dir__) + '..'
  end
end

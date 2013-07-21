require 'pathname'

module Twigg
  autoload :App,       'twigg/app'
  autoload :Command,   'twigg/command'
  autoload :Commit,    'twigg/commit'
  autoload :CommitSet, 'twigg/commit_set'
  autoload :Config,    'twigg/config'
  autoload :Gatherer,  'twigg/gatherer'
  autoload :Repo,      'twigg/repo'
  autoload :Settings,  'twigg/settings'
  autoload :Util,      'twigg/util'
  autoload :VERSION,   'twigg/version'

  # Returns a Pathname instance corresponding to the root directory of the gem
  # (ie. the directory containing the `files`, `lib`, `public`, `templates` and
  # `views` directories).
  def self.root
    Pathname.new(__dir__) + '..'
  end
end

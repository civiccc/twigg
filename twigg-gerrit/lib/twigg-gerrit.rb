require 'twigg'
require 'twigg/command'

module Twigg
  autoload :Gerrit, 'twigg-gerrit/gerrit'

  class Command
    autoload :Gerrit, 'twigg-gerrit/command/gerrit'
  end
end

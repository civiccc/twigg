require 'twigg'
require 'twigg/command'

module Twigg
  autoload :App, 'twigg-app/app'

  class Command
    autoload :App, 'twigg-app/command/app'
  end
end

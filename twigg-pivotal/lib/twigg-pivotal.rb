require 'twigg'
require 'twigg/command'

module Twigg
  autoload :Pivotal, 'twigg-pivotal/pivotal'

  class Command
    autoload :Pivotal, 'twigg-pivotal/command/pivotal'
  end
end

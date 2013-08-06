module Twigg
  module App
    autoload :Quips,   'twigg-app/app/quips'
    autoload :Routes,  'twigg-app/app/routes'
    autoload :Server,  'twigg-app/app/server'
    autoload :VERSION, 'twigg-app/app/version'

    # Returns a Pathname instance corresponding to the root directory of the gem
    # (ie. the directory containing the `lib`, `public`  and `views` directories).
    def self.root
      Pathname.new(__dir__) + '..' + '..'
    end
  end
end

require 'yaml'

module Twigg
  module App
    module Quips
      QUIPS = YAML.load_file(App.root + 'data' + 'quips.yml')

      def self.random
        QUIPS.sample
      end
    end
  end
end

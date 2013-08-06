require 'yaml'

module Twigg
  module App
    module Quips
      QUIPS = YAML.load_file(Twigg::App.root + 'data' + 'quips.yml')

      def self.random
        QUIPS[rand(QUIPS.size)]
      end
    end
  end
end

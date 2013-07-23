module Twigg
  class Command
    class Init < Command
      def initialize(*args)
        super
        ignore @args
      end

      def run
        path = Twigg.root + 'templates' + 'twiggrc.yml'
        IO.copy_stream(path, STDOUT)
      end
    end
  end
end

module Twigg
  class Command
    class Init < Command
      def initialize(*args)
        super
        ignore @args
      end

      def run
        path = File.expand_path('twiggrc.yml',
                                File.join(__dir__, '..', '..', '..', 'templates'))
        IO.copy_stream(path, STDOUT)
      end
    end
  end
end

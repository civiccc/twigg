module Twigg
  class Command
    class App < Command
      def initialize(*args)
        super
        @daemon  = @args.delete('-D') || @args.delete('--daemon')
        @pidfile = consume_option(%w[-P --pidfile], @args)
        @pidfile_path = File.expand_path(@pidfile) if @pidfile
        ignore @args
      end

      def run
        stderr 'Daemonizing...' if @daemon
        stderr "Will write to pidfile #{@pidfile}" if @pidfile_path
        die 'Pidfile already exists' if File.exist?(@pidfile_path)

        Process.daemon if @daemon

        if @pidfile_path
          flags = File::WRONLY | File::CREAT | File::EXCL
          File.open(@pidfile_path, flags) { |f| f.write Process.pid }
          at_exit { File.unlink(@pidfile_path) }
        end

        ::Twigg::App::Server.run!
      end
    end
  end
end

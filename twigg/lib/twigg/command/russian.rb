module Twigg
  class Command
    class Russian < Command
      def initialize(*args)
        super
        Help.new('russian').run! if @args.size > 2

        @repositories_directory = @args[0] || Config.repositories_directory
        @days                   = (@args[1] || Config.default_days).to_i
      end

      def run
        commit_set = Gatherer.gather(@repositories_directory, @days)
        puts RussianNovel.new(commit_set).data['children'].to_yaml
      end
    end
  end
end

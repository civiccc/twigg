module Twigg
  class Command
    class Stats < Command
      def initialize(*args)
        if args.delete('-v') || args.delete('--verbose')
          @verbose = true
        end

        if args.size > 2 || args.include?('-h') || args.include?('--help')
          Help.new('stats')
          die
        end

        @repositories_directory = args[0] || Config.repositories_directory
        @days                   = args[1] || Config.default_days

        run
      end

    private

      # Convenience method.
      def number_with_delimiter(integer)
        Util.number_with_delimiter(integer)
      end

      def run
        additions, deletions = 0, 0
        master_set = Twigg::Gatherer.gather(@repositories_directory, @days)
        master_set.top_authors.each do |top_author_data|
          author     = top_author_data[:author]
          commit_set = top_author_data[:commit_set]
          breakdown = commit_set.count_by_repo.map do |data|
            "#{data[:repo_name]}: #{number_with_delimiter data[:count]}"
          end.join(', ')
          puts '%5s %-24s %s' % [
            number_with_delimiter(commit_set.count),
            author,
            breakdown,
          ]

          if @verbose
            puts
            commit_set.commits.each do |commit|
              puts '    %5s, %5s %s [%s]' % [
                "+#{number_with_delimiter commit.stat[:additions]}",
                "-#{number_with_delimiter commit.stat[:deletions]}",
                commit.subject,
                commit.repo.name,
              ]

              additions += commit.stat[:additions]
              deletions += commit.stat[:deletions]
            end
            puts
          end
        end

        if @verbose
          puts '-----------------'
          puts '%4s %5s, %5s' % [
            number_with_delimiter(master_set.count),
            "+#{number_with_delimiter additions}",
            "-#{number_with_delimiter deletions}",
          ]
        else
          puts '----'
          puts '%4s' % number_with_delimiter(master_set.count)
        end
      end
    end
  end
end

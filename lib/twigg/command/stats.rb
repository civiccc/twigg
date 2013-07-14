module Twigg
  class Command
    class Stats < Command
      def initialize(*args)
        if args.delete('-v') || args.delete('--verbose')
          @verbose = true
        end

        if args.size != 2 || args.include?('-h') || args.include?('--help')
          Help.new('stats')
          die
        end

        @dir, @days = args[0], args[1].to_i

        run
      end

    private

      def run
        additions, deletions = 0, 0
        master_set = Twigg::Gatherer.gather(@dir, @days)
        master_set.top_authors.each do |top_author_data|
          author     = top_author_data[:author]
          commit_set = top_author_data[:commit_set]
          breakdown = commit_set.count_by_repo.
            map { |data| "#{data[:repo_name]}:#{data[:count]}" }.join(', ')
          puts '%4d %-24s %s' % [commit_set.count, author, breakdown]

          if @verbose
            puts
            commit_set.commits.each do |commit|
              puts '    %5s, %5s %s [%s]' % [
                "+#{commit.stat[:additions]}",
                "-#{commit.stat[:deletions]}",
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
          puts '%4d %5s, %5s' % [
            master_set.count,
            "+#{additions}",
            "-#{deletions}",
          ]
        else
          puts '----'
          puts '%4d' % master_set.count
        end
      end
    end
  end
end

module Twigg
  class Command
    class Stats < Command
      include Util

      def initialize(*args)
        super
        Help.new('stats').run! if @args.size > 2

        @repositories_directory = @args[0] || Config.repositories_directory
        @days                   = (@args[1] || Config.default_days).to_i
      end

      def run
        global_additions, global_deletions = 0, 0
        master_set = Twigg::Gatherer.gather(@repositories_directory, @days)
        master_set.top_authors.each do |top_author_data|
          author     = top_author_data[:author]
          commit_set = top_author_data[:commit_set]
          puts '%5s %-24s %s' % [
            number_with_delimiter(commit_set.count),
            author,
            breakdown(commit_set, html: false),
          ]

          author_additions, author_deletions = 0, 0
          if @verbose
            puts
            commit_set.commits.each do |commit|
              puts '    %5s, %5s %s [%s]' % [
                "+#{number_with_delimiter commit.stat[:additions]}",
                "-#{number_with_delimiter commit.stat[:deletions]}",
                commit.subject,
                commit.repo.name,
              ]

              author_additions += commit.stat[:additions]
              author_deletions += commit.stat[:deletions]
            end

            puts '-----------------'
            puts '    %5s, %5s' % [
              "+#{number_with_delimiter author_additions}",
              "-#{number_with_delimiter author_deletions}",
            ]
            puts
          end
          global_additions += author_additions
          global_deletions += author_deletions
        end

        if @verbose
          puts '================='
          puts '%4s %5s, %5s' % [
            number_with_delimiter(master_set.count),
            "+#{number_with_delimiter global_additions}",
            "-#{number_with_delimiter global_deletions}",
          ]
        else
          puts '----'
          puts '%4s' % number_with_delimiter(master_set.count)
        end
      end
    end
  end
end

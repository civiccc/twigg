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
        master_set = Twigg::Gatherer.gather(@repositories_directory, @days)
        master_set.authors.each do |top_author_data|
          author     = top_author_data[:author]
          commit_set = top_author_data[:commit_set]
          puts '%5s %-24s %s' % [
            number_with_delimiter(commit_set.count),
            author,
            breakdown(commit_set, html: false),
          ]

          if @verbose
            puts
            commit_set.each do |commit|
              puts '    %5s, %5s %s [%s]' % [
                "+#{number_with_delimiter commit.stat[:additions]}",
                "-#{number_with_delimiter commit.stat[:deletions]}",
                commit.subject,
                commit.repo.name,
              ]
            end

            puts '-----------------'
            puts '    %5s, %5s' % [
              "+#{number_with_delimiter commit_set.additions}",
              "-#{number_with_delimiter commit_set.deletions}",
            ]
            puts
          end
        end

        if @verbose
          puts '================='
          puts '%4s %5s, %5s' % [
            number_with_delimiter(master_set.count),
            "+#{number_with_delimiter master_set.additions}",
            "-#{number_with_delimiter master_set.deletions}",
          ]
        else
          puts '----'
          puts '%4s' % number_with_delimiter(master_set.count)
        end
      end
    end
  end
end

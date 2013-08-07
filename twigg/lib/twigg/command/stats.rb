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
        w0, w1, w2 = stats_widths(master_set)

        master_set.authors.each do |author_data|
          author     = author_data[:author]
          commit_set = author_data[:commit_set]
          puts '%5s %-24s %s' % [
            number_with_delimiter(commit_set.count),
            author,
            breakdown(commit_set, html: false),
          ]

          if @verbose
            puts
            commit_set.each do |commit|
              puts (' ' * w0) + " %#{w1}s, %#{w2}s %s [%s]" % [
                "+#{number_with_delimiter commit.stat[:additions]}",
                "-#{number_with_delimiter commit.stat[:deletions]}",
                commit.subject,
                commit.repo.name,
              ]
            end

            totals = (' ' * w0) + " %#{w1}s, %#{w2}s" % [
              "+#{number_with_delimiter commit_set.additions}",
              "-#{number_with_delimiter commit_set.deletions}",
            ]
            puts '-' * totals.length
            puts totals
            puts
          end
        end

        if @verbose
          totals = "%-#{w0}s %#{w1}s, %#{w2}s" % [
            number_with_delimiter(master_set.count),
            "+#{number_with_delimiter master_set.additions}",
            "-#{number_with_delimiter master_set.deletions}",
          ]
          puts '=' * totals.length
          puts totals
        else
          totals = "%#{w0}s" % number_with_delimiter(master_set.count)
          puts '-' * totals.length
          puts totals
        end
      end

      # Returns a tuple of "column" widths with sufficient space to represent
      # the commit count, addition count and deletion count for the given
      # {CommitSet}, `master_set`.
      def stats_widths(master_set)
        [
          number_with_delimiter(master_set.count).length,
          number_with_delimiter(master_set.additions).length + 1, # room for sign
          number_with_delimiter(master_set.deletions).length + 1, # room for sign
        ]
      end
    end
  end
end

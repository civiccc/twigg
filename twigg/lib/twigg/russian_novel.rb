module Twigg
  class RussianNovel
    # The class takes a {CommitSet} and produces data that can be used to
    # produce a d3 bubble chart:
    #
    #   https://github.com/mbostock/d3/wiki/Pack-Layout
    #   http://bl.ocks.org/mbostock/4063269
    #
    # The bubble chart is an excellent format for representing the
    # "Russianness" of an author's commit messages:
    #
    #   - size:  commit message line count (also known as "Russianness")
    #   - text:  author name
    #   - hover: detailed stats on "Russianness", Flesch Reading Ease score,
    #            author and team name
    #   - color: team
    #
    def initialize(commit_set)
      @commit_set = commit_set
    end

    # Returns Russian Novel data in a d3-friendly format.
    def data
      @data ||= begin
        team_map = Team.author_to_team_map

        children = @commit_set.authors.map do |object|
          {
            'author'              => object[:author],
            'russianness'         => object[:commit_set].russianness,
            'flesch_reading_ease' => object[:commit_set].flesch_reading_ease,
            'team'                => team_map[object[:author]],
          }
        end

        { 'children' => children }
      end
    end
  end
end

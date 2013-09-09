module Twigg
  module App
    module Routes
      def author_path(author)
        '/authors/' + author.tr(' ', '.')
      end

      def authors_path(options = {})
        '/authors' + query_string_from_options(options)
      end

      def gerrit_authors_path
        '/gerrit/authors'
      end

      def gerrit_changes_path
        '/gerrit'
      end

      def gerrit_tags_path
        '/gerrit/tags'
      end

      def pairs_path(options = {})
        '/pairs' + query_string_from_options(options)
      end

      def pivotal_path(options = {})
        '/pivotal' + query_string_from_options(options)
      end

      def russian_novels_path(options = {})
        '/russian-novels' + query_string_from_options(options)
      end

      def team_path(team)
        '/teams/' + team.tr(' ', '.')
      end

      def teams_path(options = {})
        '/teams' + query_string_from_options(options)
      end

    private

      def query_string_from_options(options)
        options.empty? ? '' : "?#{::URI.encode_www_form(options)}"
      end
    end
  end
end

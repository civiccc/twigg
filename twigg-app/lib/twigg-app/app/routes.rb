module Twigg
  class App
    module Routes
      def author_path(author)
        '/authors/' + author.tr(' ', '.')
      end

      def authors_path(options = {})
        '/authors' + (options.empty? ? '' : "?#{::URI.encode_www_form(options)}")
      end

      def pairs_path(options = {})
        '/pairs' + (options.empty? ? '' : "?#{::URI.encode_www_form(options)}")
      end

      def team_path(team)
        '/teams/' + team.tr(' ', '.')
      end

      def teams_path(options = {})
        '/teams' + (options.empty? ? '' : "?#{::URI.encode_www_form(options)}")
      end
    end
  end
end

require 'net/http'
require 'net/https'
require 'json'

module Twigg
  class Command
    # The "github" subcommand can be used to conveniently initialize a set of
    # repos and keep them up-to-date.
    class GitHub < GitHost
    private

      def address(project)
        "git@github.com:#{Config.github.organization}/#{project}.git"
      end

      API_HOST           = 'api.github.com'
      API_PORT           = 443
      ORG_REPOS_ENDPOINT = '/orgs/%s/repos'

      # Returns the list of all projects hosted within a GitHub organization.
      def projects
        @projects ||= begin
          http             = Net::HTTP.new(API_HOST, API_PORT)
          http.use_ssl     = true
          http.ca_file     = (Twigg.root + 'files' + 'github.pem').to_s
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          uri              = ORG_REPOS_ENDPOINT % Config.github.organization
          headers          = { 'Authorization' => "token #{Config.github.token}" }

          [].tap do |names|
            begin # loop: page through project list
              request  = Net::HTTP::Get.new(uri, headers)
              response = http.request(request)
              raise "Bad response #{response.inspect}" unless response.is_a?(Net::HTTPOK)
              names.concat JSON[response.body].map { |repo| repo['name'] }
              uri = parse_link(response['Link'])
            end until uri.nil?
          end
        end
      end

      # Parse the next page's URI out of a Link header, which will be of the
      # form:
      #
      #     <https://api.github.com/organizations/1234/repos?page=2>; rel="next",
      #     <https://api.github.com/organizations/1234/repos?page=N>; rel="last"
      #
      # (Linebreak included for readability; in the real headers there are no
      # linebreaks.)
      #
      # We split on "," to get a list of links, find the first link labeled as
      # `rel="next'`, and then extract the URI from inside the corresponding
      # angle brackets.
      #
      # Returns a `URI` object on success, and `nil` if no suitable link was
      # present.
      def parse_link(header)
        link = header.split(',').find do |link|
          rel = link.split(';').last
          rel && rel =~ /rel="next"/
        end

        URI(link.split(';').first.gsub(/\A<|>\z/, '')) if link
      end
    end
  end
end

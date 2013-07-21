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
          files_dir        = File.join(__dir__, '..', '..', '..', 'files')
          ca_file          = File.expand_path('github.pem', files_dir)
          http.ca_file     = ca_file
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          path             = ORG_REPOS_ENDPOINT % Config.github.organization
          query            = nil
          headers          = { 'Authorization' => "token #{Config.github.token}" }

          [].tap do |names|
            loop do # paginate through project list
              uri              = [path, query].compact.join('?')
              request          = Net::HTTP::Get.new(uri, headers)
              response         = http.request(request)
              raise "Bad response #{response.inspect}" unless response.is_a?(Net::HTTPOK)
              names.concat JSON[response.body].map { |repo| repo['name'] }

              if link = response['Link']
                link = link.split(',').find do |link|
                  rel = link.split(';').last
                  rel && rel =~ /rel="next"/
                end

                if link
                  query = URI(link.split(';').first.gsub(/\A<|>\z/, '')).query
                  next
                end
              end

              break
            end
          end
        end
      end
    end
  end
end

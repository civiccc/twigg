require 'net/http'
require 'net/https'
require 'json'

module Twigg
  class Command
    # The "github" subcommand can be used to conveniently initialize a set of
    # repos and keep them up-to-date.
    class GitHub < Command
      SUB_SUBCOMMANDS = %w[clone update]

      def initialize(*args)
        super
        @sub_subcommand = @args.first

        Help.new('github').run! unless (1..2).cover?(@args.size) &&
          SUB_SUBCOMMANDS.include?(@sub_subcommand)

        @repositories_directory = @args[1] || Config.repositories_directory
      end

      def run
        send @sub_subcommand
      end

    private

      def for_each_repo(&block)
        Dir.chdir @repositories_directory do
          projects.each do |project|
            print @verbose ? "#{project}: " : '.'
            block.call(project)
            puts ' done' if @verbose
          end
          puts
        end
      end

      def clone
        for_each_repo do |project|
          if File.directory?(project)
            print 'skipping (already present);' if @verbose
          else
            print 'cloning...' if @verbose
            git_clone(project)
          end
        end
      end

      def update
        for_each_repo do |project|
          if File.directory?(project)
            Dir.chdir project do
              print 'pulling...' if @verbose
              git_pull
            end
          else
            print 'skipping (not present);' if @verbose
          end
        end
      end

      # Convenience method for running a Git command that is expected to succeed
      # (raises an error if a non-zero exit code is produced).
      def git(*args)
        Process.wait(IO.popen(%w[git] + args).pid)
        raise unless $?.success?
      end

      # Runs `git clone` to obtain the specified `project`.
      def git_clone(project)
        git 'clone', '--quiet', address(project)
      end

      # Runs `git fetch --quiet` followed by `git merge --ff-only --quiet
      # FETCH_HEAD`.
      #
      # We do this as two commands rather than a `git pull` because the latter
      # is much fussier about tracking information being in place.
      def git_pull
        git 'fetch', '--quiet'
        git 'merge', '--ff-only', '--quiet', 'FETCH_HEAD'
      rescue => e
        # could die here if remote doesn't contain any commits yet
      end

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

require 'compass'
require 'haml'
require 'json'
require 'sass'
require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/respond_with'
require 'sprockets'
require 'yaml'

module Twigg
  module App
    class Server < Sinatra::Base
      extend Dependency

      set :bind,       Config.app.bind
      set :public_dir, App.root + 'public'
      set :views,      [App.root + 'views', App.root + 'assets']
      set :assets,     (Sprockets::Environment.new(App.root) do |env|
        env.append_path 'assets/javascripts'
      end)

      configure do
        Compass.configuration do |config|
          config.project_path = __dir__
          config.sass_dir     = 'assets/stylesheets'
        end

        set :sass, Compass.sass_engine_options
        set :scss, Compass.sass_engine_options
      end

      configure :development do
        require 'sinatra/reloader'
        register Sinatra::Reloader

        # watch for changes to lib files of any twigg gems
        also_reload App.root + '../*/lib/**/*'
      end

      register Sinatra::RespondWith

      helpers Sinatra::ContentFor
      helpers Twigg::App::Routes
      helpers Twigg::Util

      helpers do
        # Support multiple view directories.
        #
        # See: https://github.com/sinatra/sinatra/commit/441b17ead90d3e3a90a3a4
        def find_template(views, name, engine, &block)
          Array(views).each { |v| super(v, name, engine, &block) }
        end

        def h(str)
          Rack::Utils.escape_html(str)
        end

        # Returns a truthy value (the "active" class) if the current request
        # corresponds to any path in `paths_or_regex`; otherwise, returns `nil`.
        #
        # @param paths_or_regex May be a String, Array of Strings, or a Regexp.
        def active?(*paths_or_regex)
          case paths_or_regex
          when Array, String
            Array(paths_or_regex).include?(request.path_info)
          when Regexp
            paths_or_regex.match(request.path_info)
          end && 'active'
        end

        def day_links
          {
            class: 'day-links glyphicon glyphicon-time',
            data: { toggle: 'popover', content: haml(:'/shared/day_links') },
            title: 'Other time intervals',
          }
        end

        def strip_tags(html)
          require 'nokogiri'
          Nokogiri::HTML(html).text
        end

        def name_to_id(name)
          name.tr(' .@', '-').downcase
        end

        def slug_to_name(slug)
          slug.tr('.', ' ')
        end

        def random_quip
          Quips.random
        end
      end

      before do
        @days = params[:days].to_i
        @days = Config.default_days if @days.zero?
      end

      get '/' do
        haml :dashboard
      end

      get '/authors' do
        @commit_set = Gatherer.gather(Config.repositories_directory, @days)
        haml :'authors/index', layout: !request.xhr?
      end

      get '/authors/:slug', provides: %i[html json] do
        @author = slug_to_name(params[:slug])
        @commit_set = Gatherer.gather(Config.repositories_directory, @days).
          select_author(@author)

        respond_to do |f|
          f.html { haml :'authors/show' }
          f.json { @commit_set.count_by_day(@days).to_json }
        end
      end

      if Config.app.gerrit.enabled
        with_dependency 'twigg-gerrit' do
          get '/gerrit' do
            @changes = Gerrit::Change.changes
            haml :'gerrit/index', layout: !request.xhr?
          end

          get '/gerrit/authors' do
            @authors = Gerrit::Author.stats(days: @days)
            haml :'gerrit/authors'
          end

          get '/gerrit/tags', provides: %i[html json] do
            @stats   = Gerrit::Tag.stats(days: @days)
            @authors = (@stats[:from].keys + @stats[:to].keys).uniq.sort
            respond_to do |f|
              f.html { haml :'gerrit/tags' }
              f.json { @stats.to_json }
            end
          end
        end
      end

      get '/javascripts/:name.js' do
        content_type 'application/javascript'
        settings.assets["#{params[:name]}.js"]
      end

      get '/pairs' do
        @pairs = Gatherer.gather(Config.repositories_directory, @days).pairs
        haml :'pairs/index', layout: !request.xhr?
      end

      get '/russian-novels', provides: %i[html json] do
        respond_to do |f|
          f.html { haml :'russian-novels/index' }
          f.json {
            commit_set = Gatherer.gather(Config.repositories_directory, @days)
            RussianNovel.new(commit_set).data.to_json
          }
        end
      end

      get '/stylesheets/:name.css' do
        content_type 'text/css', charset: 'utf-8'
        scss :"stylesheets/#{params[:name]}"
      end

      get '/teams' do
        @commit_set = Gatherer.gather(Config.repositories_directory, @days)
        haml :'teams/index', layout: !request.xhr?
      end

      get '/teams/:slug', provides: %i[html json] do
        @team = slug_to_name(params[:slug])
        @commit_set = Gatherer.gather(Config.repositories_directory, @days).
          select_team(@team)

        respond_to do |f|
          f.html { haml :'teams/show' }
          f.json { @commit_set.count_by_day(@days).to_json }
        end
      end
    end
  end
end

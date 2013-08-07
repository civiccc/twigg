require 'haml'
require 'json'
require 'sinatra'
require 'sinatra/content_for'
require 'yaml'

module Twigg
  module App
    class Server < Sinatra::Base
      extend Dependency

      set :bind,       Config.app.bind
      set :public_dir, App.root + 'public'
      set :views,      App.root + 'views'

      configure :development do
        require 'sinatra/reloader'
        register Sinatra::Reloader

        # watch for changes to lib files of any twigg gems
        also_reload App.root + '../*/lib/**/*'
      end

      helpers Sinatra::ContentFor
      helpers Twigg::App::Routes
      helpers Twigg::Util

      helpers do
        def active?(path)
          'active' if request.path_info == path
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

      get '/authors/:slug' do
        @author = slug_to_name(params[:slug])
        @commit_set = Gatherer.gather(Config.repositories_directory, @days).
          select_author(@author)
        @nvd3_data = @commit_set.count_by_day(@days).map do |object|
          { x: object[:date].to_s, y: object[:count] }
        end
        haml :'authors/show'
      end

      if Config.app.gerrit.enabled
        with_dependency 'twigg-gerrit' do
          get '/gerrit' do
            @changes = Gerrit::Change.changes
            haml :'gerrit/index', layout: !request.xhr?
          end
        end
      end

      get '/pairs' do
        @pairs = Gatherer.gather(Config.repositories_directory, @days).pairs
        haml :'pairs/index', layout: !request.xhr?
      end

      get '/teams' do
        @commit_set = Gatherer.gather(Config.repositories_directory, @days)
        haml :'teams/index', layout: !request.xhr?
      end

      get '/teams/:slug' do
        @team = slug_to_name(params[:slug])
        @commit_set = Gatherer.gather(Config.repositories_directory, @days).
          select_team(@team)
        @nvd3_data = @commit_set.count_by_day(@days).map do |object|
          { x: object[:date].to_s, y: object[:count] }
        end
        haml :'teams/show'
      end
    end
  end
end

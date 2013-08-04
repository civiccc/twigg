require 'haml'
require 'json'
require 'sinatra'
require 'sinatra/content_for'
require 'yaml'

module Twigg
  class App < Sinatra::Base
    autoload :Quips,   'twigg-app/app/quips'
    autoload :Routes,  'twigg-app/app/routes'
    autoload :VERSION, 'twigg-app/app/version'

    # Returns a Pathname instance corresponding to the root directory of the gem
    # (ie. the directory containing the `lib`, `public`  and `views` directories).
    def self.root
      Pathname.new(__dir__) + '..' + '..'
    end

    set :bind,       Config.app.bind
    set :public_dir, root + 'public'
    set :views,      root + 'views'

    configure :development do
      require 'sinatra/reloader'
      register Sinatra::Reloader

      # watch for changes to lib files of any twigg gems
      also_reload root + '../*/lib/**/*'
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

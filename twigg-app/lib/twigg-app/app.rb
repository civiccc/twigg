require 'haml'
require 'json'
require 'sinatra'
require 'sinatra/content_for'
require 'yaml'

module Twigg
  class App < Sinatra::Base
    autoload :VERSION, 'twigg-app/version'

    # Returns a Pathname instance corresponding to the root directory of the gem
    # (ie. the directory containing the `lib`, `public`  and `views` directories).
    def self.root
      Pathname.new(__dir__) + '..' + '..'
    end

    set :bind,       Config.app.bind
    set :public_dir, root + 'public'
    set :views,      root + 'views'

    helpers Sinatra::ContentFor
    helpers Twigg::Util

    helpers do
      def author_path(author)
        '/authors/' + author.tr(' ', '.')
      end

      def team_path(team)
        '/teams/' + team.tr(' ', '.')
      end

      def name_to_id(name)
        name.tr(' .@', '-').downcase
      end

      def slug_to_name(slug)
        slug.tr('.', ' ')
      end
    end

    get '/' do
      haml :dashboard
    end

    get '/authors' do
      @days = params.fetch('days', Config.default_days).to_i
      @commit_set = Gatherer.gather(Config.repositories_directory, @days)
      haml :'authors/index', layout: !request.xhr?
    end

    get '/authors/:slug' do
      @days= params.fetch('days', Config.default_days).to_i
      master_set = Gatherer.gather(Config.repositories_directory, @days)
      @author = slug_to_name(params[:slug])
      @commit_set = master_set.select_author(@author)
      @nvd3_data = @commit_set.count_by_day(@days).map do |object|
        { x: object[:date].to_s, y: object[:count] }
      end
      haml :'authors/show'
    end

    get '/teams' do
      @days = params.fetch('days', Config.default_days).to_i
      @commit_set = Gatherer.gather(Config.repositories_directory, @days)
      haml :'teams/index', layout: !request.xhr?
    end

    get '/teams/:slug' do
      @team = slug_to_name(params[:slug])
      haml :'teams/show'
    end
  end
end

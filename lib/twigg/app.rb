require 'haml'
require 'json'
require 'sinatra'
require 'sinatra/content_for'
require 'yaml'

module Twigg
  class App < Sinatra::Base
    def self.config
      @config ||= begin
        config = File.expand_path('../../config.yml',  File.dirname(__FILE__))
        YAML.load_file(config)
      end
    end

    set :bind, config['bind']
    set :public_dir, File.expand_path('app/public', File.dirname(__FILE__))
    set :repositories_directory, config['repositories_directory']
    set :views, File.expand_path('app/views', File.dirname(__FILE__))

    helpers Sinatra::ContentFor

    helpers do
      def name_to_slug(name)
        name.tr(' ', '.')
      end

      def slug_to_name(slug)
        slug.tr('.', ' ')
      end

      def breakdown(commit_set)
        commit_set.count_by_repo.map do |data|
          "<i>#{data[:repo_name]}:</i> <b>#{data[:count]}</b>"
        end.join(', ')
      end
    end

    get '/' do
      @days_ago = params.fetch('days_ago', 14).to_i
      @commit_set = Gatherer.gather(settings.repositories_directory, @days_ago)
      haml :commit_stats
    end

    get '/:slug' do
      @days_ago = 90
      master_set = Gatherer.gather(settings.repositories_directory, @days_ago)
      @author = slug_to_name(params[:slug])
      @commit_set = master_set.select_author(@author)
      @nvd3_data = @commit_set.count_by_day(@days_ago).map do |object|
        { x: object[:date].to_s, y: object[:count] }
      end
      haml :profile
    end
  end
end

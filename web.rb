require 'bundler'
Bundler.require
require File.expand_path('../lib/quant',  __FILE__)
require 'sinatra'
require 'haml'
require 'yaml'

config_file = File.expand_path('../config.yml',  __FILE__)
config = YAML.load(File.read(config_file))
set :repositories_directory, config['repositories_directory']

helpers do
  def name_to_slug(name)
    name.tr(' ', '.')
  end

  def slug_to_name(slug)
    slug.tr('.', ' ')
  end

  def breakdown(commit_set)
    commit_set.count_by_repo.map do |data|
      "#{data[:repo_name]}:#{data[:count]}"
    end.join(', ')
  end
end

get '/' do
  @days_ago = params.fetch('days_ago', 14).to_i
  @commit_set = Quant::Gatherer.gather(settings.repositories_directory, @days_ago)
  haml :commit_stats
end

get '/:slug' do
  @days_ago = 90
  master_set = Quant::Gatherer.gather(settings.repositories_directory, @days_ago)
  @author = slug_to_name(params[:slug])
  @commit_set = master_set.select_author(@author)
  haml :profile
end

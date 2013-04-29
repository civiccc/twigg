require 'bundler'
Bundler.require
require File.expand_path('../lib/quant',  __FILE__)
require 'sinatra'
require 'haml'
require 'yaml'

config_file = File.expand_path('../config.yml',  __FILE__)
config = YAML.load(File.read(config_file))
set :repositories_directory, config['repositories_directory']

get '/' do
  repositories = Dir[File.join(settings.repositories_directory, '*')]
  @days_ago = params.fetch('days_ago', 14).to_i
  since = Time.now - @days_ago*24*60*60
  @commit_stats = Quant::CommitStats.new(repositories, since)
  haml :commit_stats
end

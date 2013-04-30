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
  @days_ago = params.fetch('days_ago', 14).to_i
  @commit_stats = Quant::CommitStats.new(settings.repositories_directory, @days_ago)
  haml :commit_stats
end

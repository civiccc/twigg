# coding: utf-8
[
  File.expand_path('lib', File.dirname(__FILE__)),
  File.expand_path('lib', File.join(File.dirname(__FILE__), '..', 'twigg')),
].each do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

require 'twigg-app'

Gem::Specification.new do |spec|
  spec.name        = 'twigg-app'
  spec.version     = Twigg::App::VERSION
  spec.authors     = ['Causes Engineering']
  spec.email       = ['eng@causes.com']
  spec.summary     = 'Web frontend to Twigg repo statistics tool'
  spec.description = <<-EOS.strip.gsub(/\s+/, ' ')
    Twigg provides stats for activity in Git repositories. This is the
    web-based interface.
  EOS
  spec.homepage    = 'https://github.com/causes/twigg'
  spec.license     = 'MIT'

  spec.files = Dir[
    'lib/**/*',
    'public/**/*',
    'views/*',
    'data/*',
  ]

  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'

  spec.add_dependency 'compass',         '~> 0.12.2'
  spec.add_dependency 'haml',            '~> 4.0.3'
  spec.add_dependency 'nokogiri',        '~> 1.6.0'
  spec.add_dependency 'sass',            '~> 3.2.10'
  spec.add_dependency 'sinatra-contrib', '~> 1.4.0'
  spec.add_dependency 'twigg',           Twigg::VERSION
end

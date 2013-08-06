# coding: utf-8
lib = File.expand_path('lib', File.dirname(__FILE__))
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'twigg'

Gem::Specification.new do |spec|
  spec.name        = 'twigg'
  spec.version     = Twigg::VERSION
  spec.authors     = ['Causes Engineering']
  spec.email       = ['eng@causes.com']
  spec.summary     = 'Statistics for Git repositories'
  spec.description = <<-EOS.strip.gsub(/\s+/, ' ')
    Twigg provides stats for activity in Git repositories.
  EOS
  spec.homepage    = 'https://github.com/causes/twigg'
  spec.license     = 'MIT'

  spec.files = Dir[
    'bin/*',
    'files/*',
    'lib/**/*',
  ]

  spec.executables   = ['twigg']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'factory_girl'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rr'
  spec.add_development_dependency 'rspec'
end

# coding: utf-8
[
  File.expand_path('lib', File.dirname(__FILE__)),
  File.expand_path('lib', File.join(File.dirname(__FILE__), '..', 'twigg')),
].each do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

require 'twigg-cache'

Gem::Specification.new do |spec|
  spec.name        = 'twigg-cache'
  spec.version     = Twigg::Cache::VERSION
  spec.authors     = ['Causes Engineering']
  spec.email       = ['eng@causes.com']
  spec.summary     = 'Memcached adapter for Twigg repo statistics tool'
  spec.description = <<-EOS.strip.gsub(/\s+/, ' ')
    Twigg provides stats for activity in Git repositories. This is the
    adapter that enables Twigg to use memcached for greater performance.
  EOS
  spec.homepage    = 'https://github.com/causes/twigg'
  spec.license     = 'MIT'

  spec.files = Dir[
    'lib/**/*',
  ]

  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'

  spec.add_dependency 'dalli'
  spec.add_dependency 'twigg', Twigg::VERSION
end

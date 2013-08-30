namespace :twigg do
  desc 'run twigg specs'
  task :spec do
    Dir.chdir('twigg') { system 'bundle exec rake' }
  end

  desc 'build twigg gem'
  task :build do
    Dir.chdir('twigg') { system 'bundle exec rake build' }
  end

  desc 'push twigg gem to RubyGems'
  task :push do
    Dir.chdir('twigg') { system 'bundle exec rake push' }
  end

  desc 'tag twigg gem'
  task :tag do
    Dir.chdir('twigg') { system 'bundle exec rake tag' }
  end
end

task default: 'twigg:spec'

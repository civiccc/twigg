%w[
  twigg
  twigg-app
  twigg-cache
  twigg-gerrit
].each do |gem|
  namespace gem do
    desc "run #{gem} specs"
    task :spec do
      Dir.chdir(gem) { system 'bundle exec rake' }
    end

    desc "build #{gem} gem"
    task :build do
      Dir.chdir(gem) { system 'bundle exec rake build' }
    end

    desc "push #{gem} gem to RubyGems"
    task :push do
      Dir.chdir(gem) { system 'bundle exec rake push' }
    end

    desc "tag #{gem} gem"
    task :tag do
      Dir.chdir(gem) { system 'bundle exec rake tag' }
    end
  end
end

task default: 'twigg:spec'

namespace :twigg do
  task :spec do
    Dir.chdir 'twigg' do
      system 'bundle exec rake'
    end
  end
end

task default: 'twigg:spec'

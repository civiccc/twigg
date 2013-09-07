require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w(-fs --color)
  t.pattern = 'spec/**/*_spec.rb'
end

task default: :spec

def prompt(prompt_string = 'Proceed')
  loop do
    print "#{prompt_string}? (y/n) "
    response = STDIN.gets.chomp
    return if response =~ /\A\s*(ye?)s?\s*\z/i
    exit if response =~ /\A\s*no?\s*\z/i
  end
end

# Like `Kernel#system`, but complains noisily in the event of an error.
def system!(*args)
  system *args

  unless $?.success?
    raise "command #{args.inspect} failed with exit status #{$?.exitstatus}"
  end
end

RELEASE_PREREQS = %i[
  require_bundle
  require_clean_worktree
  require_gerrit_annotations
]

task :require_bundle do
  system! 'bundle check'
end

task :require_clean_worktree do
  system 'git diff --quiet'
  if !$?.success? && !ENV['ALLOW_DIRTY_WORKTREE']
    raise 'worktree is dirty (set ALLOW_DIRTY_WORKTREE=1 to force)'
  end
end

task :require_gerrit_annotations do
  required_annotations = [
    %r{^ {4}Change-Id: I[0-9a-f]{40}$},
    %r{^ {4}Reviewed-on: https://gerrit\.causes\.com/\d{5,}$},
    %r{^ {4}Reviewed-by: .+ <.+@.+>$},
    %r{^ {4}Tested-by: .+ <.+@.+>$},
  ]

  head = `git log -1`
  unless required_annotations.all? { |regexp| head =~ regexp }
    raise 'required Gerrit annotations missing (was commit not cherry-picked?)'
  end
end

gem = "#{@gem}-#{@version}.gem"
file gem do
  system "gem build #{@gem}.gemspec"
end

desc "build #{@gem} gem (#{gem})"
task build: gem

desc "push #{@gem} gem (#{gem}) to RubyGems"
task push: [gem] + RELEASE_PREREQS do
  prompt "Push #{@gem} to RubyGems"
  system "gem push #{gem}"
end

tag = "#{@gem}/v#{@version}"
desc "tag #{@gem} release (#{tag})"
task tag: RELEASE_PREREQS do
  system 'git log -1'
  puts
  message = "#{@version} release"
  prompt "Tag current HEAD (shown above) with #{tag} (#{message})"
  system! "git tag #{tag} -m '#{message}'"

  puts
  system 'git remote show -n origin'
  puts
  prompt "Push tags to origin (shown above)"
  system! 'git push origin --tags'
end

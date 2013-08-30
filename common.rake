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

task :require_bundle do
  system 'bundle check'
  if !$?.success?
    raise 'bundle check failed'
  end
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

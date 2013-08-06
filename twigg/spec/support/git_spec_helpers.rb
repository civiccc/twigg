require 'tmpdir'

module GitSpecHelpers
  extend self

  def scratch_repo(bare: false, &block)
    Dir.mktmpdir.tap do |path|
      Dir.chdir(path) do
        bare ? `git init --bare` : `git init`
        block.call if block_given?
      end
    end
  end
end

require 'twigg'

Dir[Twigg.root + 'spec/support/**/*.rb'].each { |f| require f.gsub(/\.rb\z/, '') }

RSpec.configure do |config|
  # order matters: `treat_symbols_as_metadata_keys_with_true_values` must come
  # before `filter_run`
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus

  config.include GitSpecHelpers
  config.mock_with :rr
  config.order = 'random'
  config.run_all_when_everything_filtered = true
end

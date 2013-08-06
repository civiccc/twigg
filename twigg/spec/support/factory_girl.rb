require 'factory_girl'

FactoryGirl.find_definitions # loads definitions from spec/factories

RSpec.configure do |config|
  # Make `build`, `build_stubbed`, `create`, `attributes_for`, and `*_list`
  # counterparts available in specs.
  config.include FactoryGirl::Syntax::Methods
end

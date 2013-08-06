require 'date'
require 'digest/sha1'
require 'yaml'

FactoryGirl.define do
  fixtures = YAML.load_file(Twigg.root + 'spec/support/fixtures.yml')

  sequence(:date) do |n|
    Time.at(n).to_date
  end

  sequence(:name) do |n|
    fixtures['first_names'].sample + ' ' + fixtures['surnames'].sample
  end

  sequence(:sha1) do |n|
    Digest::SHA1.hexdigest(n.to_s)
  end

  sequence(:subject) do |n|
    fixtures['subjects'].sample
  end
end

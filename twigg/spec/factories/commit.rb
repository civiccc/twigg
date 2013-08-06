require 'ostruct'

FactoryGirl.define do
  factory :commit, class: Twigg::Commit do
    author  { generate(:name) }
    commit  { generate(:sha1) }
    date    { generate(:date) }
    repo    { OpenStruct.new(name: 'foo') }
    stat    { { additions: rand(100), deletions: rand(100) } }
    subject { generate(:subject) }

    initialize_with { new(attributes) }
  end
end

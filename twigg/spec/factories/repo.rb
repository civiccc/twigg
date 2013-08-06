FactoryGirl.define do
  factory :repo, class: Twigg::Repo do
    ignore do
      path { GitSpecHelpers.scratch_repo }
    end

    initialize_with { new(path) }
  end
end

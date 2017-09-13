FactoryGirl.define do
  factory :published_work do
    transient do
      user { FactoryGirl.create(:user) }
    end

    title ["Test title"]

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user)
    end
  end
end

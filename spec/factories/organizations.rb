FactoryBot.define do
  factory :organization do
    name { Faker::Company.name }
    association :plan
    subscription_status { 'active' }
    trial_ends_at { 30.days.from_now }
    
    settings do
      {
        notification_email: nil,
        timezone: 'UTC',
        date_format: 'YYYY-MM-DD'
      }
    end

    usage_limits do
      {
        daily_api_calls: 1000,
        max_file_size_mb: 100,
        max_rows_per_import: 100000
      }
    end

    trait :with_premium_plan do
      association :plan, factory: :plan, name: 'Premium'
    end

    trait :with_basic_plan do
      association :plan, factory: :plan, name: 'Basic'
    end
  end
end
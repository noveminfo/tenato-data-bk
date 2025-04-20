FactoryBot.define do
  factory :plan do
    name { 'Basic' }
    monthly_price { 29.99 }
    features { { data_sources: true, api_access: false, support: 'email' } }
    max_users { 5 }
    max_data_sources { 3 }
    max_storage_gb { 10 }
    api_access_enabled { false }

    trait :premium do
      name { 'Premium' }
      monthly_price { 99.99 }
      features { { data_sources: true, api_access: true, support: '24/7' } }
      max_users { 20 }
      max_data_sources { 10 }
      max_storage_gb { 50 }
      api_access_enabled { true }
    end
  end
end
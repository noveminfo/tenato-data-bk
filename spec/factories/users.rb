FactoryBot.define do
  factory :user do
    email { "MyString" }
    password_digest { "MyString" }
    role { "MyString" }
    organization { nil }
    deleted_at { "2025-04-15 05:59:18" }
  end
end

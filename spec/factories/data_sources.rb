FactoryBot.define do
  factory :data_source do
    name { Faker::App.name }
    source_type { %w[csv api].sample }
    status { 'active' }
    association :organization

    trait :csv do
      source_type { 'csv' }
    end

    trait :api do
      source_type { 'api' }
    end

    trait :active do
      status { 'active' }
    end

    trait :inactive do
      status { 'inactive' }
    end

    # インポート履歴付きのデータソースを作成するトレイト
    trait :with_import_history do
      after(:create) do |data_source|
        create(:import_history, data_source: data_source)
      end
    end

    # 複数のインポート履歴を持つデータソースを作成するトレイト
    trait :with_multiple_import_histories do
      after(:create) do |data_source|
        create_list(:import_history, 3, data_source: data_source)
      end
    end
  end
end
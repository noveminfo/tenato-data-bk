FactoryBot.define do
  factory :import_history do
    association :data_source
    file_name { "#{Time.current.strftime('%Y%m%d%H%M%S')}_import.csv" }
    status { 'pending' }
    total_rows { 0 }
    processed_rows { 0 }
    error_rows { 0 }
    error_details { nil }

    trait :pending do
      status { 'pending' }
    end

    trait :processing do
      status { 'processing' }
      total_rows { 100 }
      processed_rows { 50 }
    end

    trait :completed do
      status { 'completed' }
      total_rows { 100 }
      processed_rows { 100 }
      error_rows { 0 }
    end

    trait :completed_with_errors do
      status { 'completed_with_errors' }
      total_rows { 100 }
      processed_rows { 90 }
      error_rows { 10 }
      error_details do
        {
          errors: [
            {
              row: 5,
              error: "Invalid data format",
              data: { "column1": "invalid_value" }
            }
          ]
        }
      end
    end

    trait :failed do
      status { 'failed' }
      error_details do
        {
          error: "Processing failed",
          message: "Unexpected error occurred"
        }
      end
    end

    # Active Storageのファイル添付をシミュレート
    trait :with_file do
      after(:build) do |import_history|
        import_history.file.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test.csv')),
          filename: 'test.csv',
          content_type: 'text/csv'
        )
      end
    end
  end
end
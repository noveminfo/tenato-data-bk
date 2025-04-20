class UpdateExistingOrganizationsWithDefaults < ActiveRecord::Migration[7.1]
  def up
    Organization.find_each do |org|
      org.settings ||= {
        notification_email: nil,
        timezone: 'UTC',
        date_format: 'YYYY-MM-DD'
      }
      org.usage_limits ||= {
        daily_api_calls: 1000,
        max_file_size_mb: 100,
        max_rows_per_import: 100000
      }
      org.save(validate: false)
    end
  end

  def down
    # No need to rollback these changes
  end
end

class Organization < ApplicationRecord
  belongs_to :plan, optional: true
  has_many :users, dependent: :destroy
  has_many :data_sources, dependent: :destroy

  validates :name, presence: true
  validates :subscription_status, inclusion: { in: %w[trial active past_due cancelled] }, allow_nil: true

  before_create :set_trial_period
  before_create :set_default_settings
  before_create :set_default_usage_limits

  def storage_usage
    # インポート履歴に関連付けられたファイルのサイズを合計
    total_bytes = data_sources
      .joins(import_histories: :file_attachment)
      .sum('active_storage_blobs.byte_size')

    # バイトをギガバイトに変換（小数点2桁まで）
    (total_bytes.to_f / (1024 * 1024 * 1024)).round(2)
  rescue StandardError => e
    Rails.logger.error "Error calculating storage usage: #{e.message}"
    0
  end

  def reached_storage_limit?
    return false if plan&.max_storage_gb.nil?
    storage_usage >= plan.max_storage_gb
  end

  private

  def set_trial_period
    self.trial_ends_at = 30.days.from_now if trial_ends_at.nil?
  end

  def set_default_settings
    self.settings ||= {
      notification_email: nil,
      timezone: 'UTC',
      date_format: 'YYYY-MM-DD'
    }
  end

  def set_default_usage_limits
    self.usage_limits ||= {
      daily_api_calls: 1000,
      max_file_size_mb: 100,
      max_rows_per_import: 100000
    }
  end
end
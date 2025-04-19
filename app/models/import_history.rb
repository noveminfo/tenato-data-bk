class ImportHistory < ApplicationRecord
  belongs_to :data_source

  has_one_attached :file

  validates :file_name, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending processing completed completed_with_errors failed] }

  scope :recent, -> { order(created_at: :desc) }

  # 時間帯別の集計
  scope :by_hour, -> { group_by_hour_of_day(:created_at).count }
  
  # 日別の集計
  scope :by_day, -> { group_by_day(:created_at, last: 30).count }
  
  # ステータス別の集計
  scope :by_status, -> { group(:status).count }

  # 成功率の計算
  def self.success_rate
    total = count
    return 0 if total.zero?

    successful = where(status: 'completed').count
    (successful.to_f / total * 100).round(2)
  end
end

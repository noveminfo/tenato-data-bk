class DataSource < ApplicationRecord
  belongs_to :organization
  has_many :import_histories, dependent: :destroy

  validates :name, presence: true
  validates :source_type, presence: true, inclusion: { in: %w[csv api] }
  validates :status, presence: true, inclusion: { in: %w[active inactive] }

  scope :active, -> { where(status: 'active') }

  def success_rate
    total = import_histories.count
    return 0 if total.zero?

    successful = import_histories.where(status: 'completed').count
    (successful.to_f / total * 100).round(2)
  end

  def recent_imports(limit = 5)
    import_histories.recent.limit(limit)
  end
end

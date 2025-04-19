class ImportHistory < ApplicationRecord
  belongs_to :data_source

  validates :file_name, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }

  scope :recent, -> { order(created_at: :desc) }
end

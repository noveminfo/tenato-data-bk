class ImportHistory < ApplicationRecord
  belongs_to :data_source

  has_one_attached :file

  validates :file_name, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending processing completed completed_with_errors failed] }

  scope :recent, -> { order(created_at: :desc) }
end

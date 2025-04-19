class DataSource < ApplicationRecord
  belongs_to :organization
  has_many :import_histories, dependent: :destroy

  validates :name, presence: true
  validates :source_type, presence: true, inclusion: { in: %w[csv api] }
  validates :status, presence: true, inclusion: { in: %w[active inactive] }

  scope :active, -> { where(status: 'active') }
end

class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :data_sources, dependent: :destroy  # この行を追加

  validates :name, presence: true
  validates :plan, presence: true, inclusion: { in: %w[basic premium] }
end

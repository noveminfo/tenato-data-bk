class Organization < ApplicationRecord
  has_many :users, dependent: :destroy

  validates :plan, presence: true, inclusion: { in: %w[basic premium] }
  validates :name, presence: true
end
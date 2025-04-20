class Plan < ApplicationRecord
  has_many :organizations

  validates :name, presence: true
  validates :monthly_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :features, presence: true
  validates :max_users, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :max_data_sources, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :max_storage_gb, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end

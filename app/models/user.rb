class User < ApplicationRecord
  belongs_to :organization

  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin user] }

  scope :active, -> { where(deleted_at: nil) }
end

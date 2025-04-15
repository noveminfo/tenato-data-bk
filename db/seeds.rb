# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 開発用組織の作成
organization = Organization.create!(
  name: 'Sample Company',
  plan: 'premium'
)

# 管理者ユーザーの作成
admin_user = User.create!(
  organization: organization,
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: 'admin'
)

# 一般ユーザーの作成
regular_user = User.create!(
  organization: organization,
  email: 'user@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: 'user'
)

puts "Seed data created successfully!"
puts "Admin user email: admin@example.com"
puts "Regular user email: user@example.com"
puts "Password for all users: password123"
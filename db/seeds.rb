# データベースをクリーンアップ
Plan.delete_all
Organization.delete_all
User.delete_all

# プランの作成
plans = [
  {
    name: 'Basic',
    monthly_price: 29.99,
    features: {
      data_sources: true,
      api_access: false,
      support: 'email'
    },
    max_users: 5,
    max_data_sources: 3,
    max_storage_gb: 10,
    api_access_enabled: false
  },
  {
    name: 'Premium',
    monthly_price: 99.99,
    features: {
      data_sources: true,
      api_access: true,
      support: '24/7'
    },
    max_users: 20,
    max_data_sources: 10,
    max_storage_gb: 50,
    api_access_enabled: true
  }
]

# プランを作成
plans.each do |plan_data|
  Plan.create!(plan_data)
end

premium_plan = Plan.find_by!(name: 'Premium')
puts "Created plans: #{Plan.count}"
puts "Premium plan ID: #{premium_plan.id}"
puts "Available plans: #{Plan.all.pluck(:id, :name)}"

begin
  # 開発用組織の作成
  organization = Organization.new(
    name: 'Sample Company',
    plan: premium_plan,  # プランを直接設定
    subscription_status: 'active',
    trial_ends_at: 30.days.from_now,
    settings: {
      notification_email: nil,
      timezone: 'UTC',
      date_format: 'YYYY-MM-DD'
    },
    usage_limits: {
      daily_api_calls: 1000,
      max_file_size_mb: 100,
      max_rows_per_import: 100000
    }
  )

  # バリデーションをチェック
  unless organization.valid?
    puts "Organization validation failed:"
    puts organization.errors.full_messages
    raise "Validation failed"
  end

  organization.save!
  puts "Organization created successfully"

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

rescue => e
  puts "Error occurred:"
  puts e.message
  puts e.backtrace.first(5)
end
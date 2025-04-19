source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'rails', '~> 7.1.0'
gem 'pg'
gem 'puma'
gem 'bcrypt'
gem 'jwt'
gem 'rack-cors'  # この行が確実に含まれていることを確認
gem 'jbuilder'
gem 'bootsnap', require: false
# Redis for token blacklisting
gem 'redis'

# Ruby 3.2対応のため追加
gem 'irb'
gem 'logger'

# Background Job
gem 'sidekiq'
gem 'sidekiq-scheduler'

# For date grouping in queries
gem 'groupdate'

group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers'
  gem 'database_cleaner-active_record'
  gem 'pry-rails'
end
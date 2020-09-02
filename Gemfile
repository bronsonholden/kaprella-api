source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.1'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.8'
  gem 'factory_bot_rails'
end

group :development do
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'rb-readline'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'sqlite3', '~> 1.3', '>= 1.3.11'
  gem 'database_cleaner'
end

gem 'api-versions', '~> 1.0'
gem 'auto_increment', '~> 1.5'
gem 'activerecord-postgis-adapter'
# tzinfo is already included as part of Rails dependencies
gem 'countries'
gem 'money', '~> 6.9'
gem 'jsonapi-realizer', git: 'https://github.com/paulholden2/jsonapi-realizer.rb.git', branch: 'core'
gem 'jsonapi-serializers'
gem 'pundit'
gem 'discard', '~> 1.0'
gem 'paper_trail'
gem 'keisan'
gem 'babel_bridge'

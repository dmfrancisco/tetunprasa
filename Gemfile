source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Administration
gem 'activeadmin', github: 'activeadmin'

# Authentication
gem 'devise'

# Database
gem 'pg'
gem 'friendly_id'

# Search
gem 'sunspot_rails'
gem 'sunspot_solr', group: :development # Pre-packaged Solr distribution

# Deployment
group :development, :test do
  gem 'capistrano', '~> 3.4'
  gem 'capistrano-rails', require: false
  gem 'capistrano-rvm', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-unicorn-nginx', require: false
  gem 'capistrano-safe-deploy-to', require: false
end

# Others
gem 'autoprefixer-rails'
gem 'hashids'
gem 'kaminari'
gem 'nokogiri'

group :development, :test do
  gem 'dotenv-rails' # Shim to load environment variables from .env into ENV in development
  gem 'pry-rails' # An IRB alternative and runtime developer console
end

# More from Rails
gem 'rails', '~> 5.0.2'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  gem 'web-console', '>= 3.3.0' # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'listen', '~> 3.0.5'
  gem 'spring' # Spring speeds up development by keeping your application running in the background
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

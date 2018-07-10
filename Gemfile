source 'https://rubygems.org'
ruby "2.4.4"
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '5.1.4'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg', '0.20.0'
#gem 'ibm_db', '~> 3.0', '>= 3.0.4'
gem 'devise'
gem 'activeadmin', '1.0.0'
gem 'net-ssh'

gem 'redis'
gem 'redis-namespace'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 5.0.6'
  gem 'coffee-rails', '~> 4.2.1'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 3.2.0'
end

gem 'bootstrap-sass'
gem 'jquery-rails', '>= 4.3.1'
gem 'font-awesome-rails', '~> 4.7', '>= 4.7.0.2'

# active admin template
gem "active_material", github: "vigetlabs/active_material"
#gem 'active_bootstrap_skin'

# adding charts
gem 'chartkick'
gem 'groupdate'

# Prevent Heroku inject plugins at deploy time
gem "cf-autoconfig", "~> 0.2.1"
gem 'rails_12factor', group: :production
# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem 'dotenv-rails'
group :development, :test do
	gem 'factory_girl_rails'
	gem 'byebug'
	gem 'better_errors'	
	gem 'binding_of_caller'
end
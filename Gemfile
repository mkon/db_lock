source 'https://rubygems.org'

# Declare your gem's dependencies in paysource.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
gem 'byebug'

group :mysql, optional: true do
  gem 'mysql2', '~> 0.5.2'
end

group :sqlserver, optional: true do
  gem 'activerecord-sqlserver-adapter', '~> 5.1.6'
  gem 'tiny_tds', '~> 2.1.2'
end

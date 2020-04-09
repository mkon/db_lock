require 'bundler/setup'
Bundler.setup
Bundler.require(:default, :development, :test)

require 'simplecov'
SimpleCov.start do
  add_filter '/spec'
end
# Coverage is hard to measure as MySQL and SQLServer run in different builds
SimpleCov.minimum_coverage 85

require 'active_record'

def skip_unless(adapter)
  before do
    skip "not using #{adapter}" unless ENV["#{adapter.upcase}_URL"]
  end
end

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

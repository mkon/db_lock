ENV['RACK_ENV'] ||= 'test'

require 'rubygems'
require 'bundler'
Bundler.require :default, 'test'

require 'simplecov'
SimpleCov.start do
  add_filter '/spec'
end
SimpleCov.minimum_coverage 96

require 'dotenv/load'
require 'active_record'

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

def skip_unless(adapter)
  before do
    skip "not using #{adapter}" unless ENV["#{adapter.upcase}_URL"]
  end
end

ActiveRecord::Base.logger = Logger.new($stdout)
ActiveRecord::Base.logger.level = Logger::Severity::INFO

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.include InOtherThread

  config.before(:suite) do
    ENV['MYSQL_URL']&.then do |url|
      MysqlA.establish_connection url
      MysqlB.establish_connection url
    end
    ENV['POSTGRES_URL']&.then do |url|
      ModelPostgres.establish_connection url
    end
  end
end

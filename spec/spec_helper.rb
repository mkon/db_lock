require 'bundler/setup'
Bundler.setup
Bundler.require(:default, :development, :test)

require 'active_record'

DB_CONFIG_MYSQL = YAML::load(IO.read('config/database_mysql.yml'))
DB_CONFIG_MSSQL = YAML::load(IO.read('config/database_mssql.yml'))


require "support/connection/mysql_a"
require "support/connection/mysql_b"
require "support/connection/mssql_a"
require "support/connection/mssql_b"

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

module Connection
  class MysqlB < ActiveRecord::Base
    establish_connection DB_CONFIG_MYSQL["test"]
  end
end

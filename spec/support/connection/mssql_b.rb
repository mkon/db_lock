module Connection
  class MssqlB < ActiveRecord::Base
    establish_connection DB_CONFIG_MSSQL['test']
  end
end

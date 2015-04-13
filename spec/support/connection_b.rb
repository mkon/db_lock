class ConnectionB < ActiveRecord::Base
  establish_connection DB_CONFIG["test"]
end

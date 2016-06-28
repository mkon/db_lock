module DBLock
  module Adapter
    extend self

    autoload :Base, "db_lock/adapter/base"
    autoload :MSSQL, "db_lock/adapter/mssql"
    autoload :MYSQL, "db_lock/adapter/mysql"

    delegate :lock, :release, to: :implementation

    def implementation
      case DBLock.db_handler.connection.adapter_name.downcase
      when 'mysql2'
        MYSQL.instance
      when 'sqlserver'
        MSSQL.instance
      else
        raise "#{DBLock.db_handler.connection.adapter_name} is not implemented"
      end
    end
  end
end

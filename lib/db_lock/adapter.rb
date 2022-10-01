module DBLock
  module Adapter
    extend self

    autoload :Base, 'db_lock/adapter/base'
    autoload :MYSQL, 'db_lock/adapter/mysql'
    autoload :Postgres, 'db_lock/adapter/postgres'
    autoload :Sqlserver, 'db_lock/adapter/sqlserver'

    delegate :lock, :release, to: :implementation

    def implementation
      case DBLock.db_handler.connection.adapter_name.downcase
      when 'mysql2'
        MYSQL.instance
      when 'postgresql'
        Postgres.instance
      when 'sqlserver'
        Sqlserver.instance
      else
        raise "#{DBLock.db_handler.connection.adapter_name} is not implemented"
      end
    end
  end
end

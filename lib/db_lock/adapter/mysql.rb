module DBLock
  module Adapter
    class MYSQL < Base
      def lock(name, timeout=0)
        sql = sanitize_sql_array "SELECT GET_LOCK(?, ?)", name, timeout
        res = connection.select_one sql
        (res && res.values.first == 1)
      end

      def release(name)
        sql = sanitize_sql_array "SELECT RELEASE_LOCK(?)", name
        res = connection.select_one sql
        (res && res.values.first == 1)
      end
    end
  end
end

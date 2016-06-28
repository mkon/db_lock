module DBLock
  module Adapter
    class Base
      include Singleton

      private

      def connection
        DBLock.db_handler.connection
      end

      def sanitize_sql_array(*args)
        DBLock.db_handler.send(:sanitize_sql_array, args)
      end
    end
  end
end

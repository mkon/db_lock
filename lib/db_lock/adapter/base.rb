module DBLock
  module Adapter
    class Base
      include Singleton

      private

      def connection
        DBLock.db_handler.connection
      end

      def pool
        DBLock.db_handler.connection_pool
      end

      def execute(*args)
        run_sanitized :execute, args
      end

      def select_one(*args)
        run_sanitized :select_one, args
      end

      def select_value(*args)
        run_sanitized :select_value, args
      end

      def sanitize_sql_array(*args)
        DBLock.db_handler.sanitize_sql_array args
      end

      def run_sanitized(command, args)
        options = args.extract_options!
        con = options[:connection] || connection
        sql = sanitize_sql_array(*args)
        con.public_send(command, sql)
      end
    end
  end
end

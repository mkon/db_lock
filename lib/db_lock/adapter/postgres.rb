require 'timeout'

module DBLock
  module Adapter
    LockTimeout = Class.new(Timeout::Error)

    class Postgres < Base
      def lock(name, timeout = 0)
        pid = connection_pid(connection)
        Timeout.timeout(timeout, LockTimeout) do
          execute 'SELECT pg_advisory_lock(hashtext(?))', name
          # Sadly this returns void in postgres
          true
        end
      rescue LockTimeout
        # We have to manually kill the lock query
        # Connection pool keeps it alive blocking one connection
        # Also it would eventually acquire the lock
        stop_query pid
        false
      end

      def release(name)
        res = select_value 'SELECT pg_advisory_unlock(hashtext(?))', name
        res == true
      end

      private

      def connection_pid(con)
        select_value 'SELECT pg_backend_pid()', connection: con
      end

      def stop_query(pid)
        with_dedicated_connection do |con|
          res = select_value 'SELECT pg_cancel_backend(?)', pid, connection: con
          res == true
        end
      end

      def with_dedicated_connection
        con = pool.checkout
        yield con
      ensure
        pool.checkin con
      end
    end
  end
end

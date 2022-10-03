require 'timeout'

module DBLock
  module Adapter
    LockTimeout = Class.new(Timeout::Error)

    class Postgres < Base
      def lock(name, timeout = 0)
        pid = connection_pid(connection)
        Timeout.timeout(timeout, LockTimeout) do
          execute lock_query(name)
          # Sadly this returns void in postgres
          true
        end
      rescue LockTimeout
        logger&.info 'DBLock: Recovering from expired lock query'
        recover_from_timeout pid, name
      end

      def release(name)
        res = select_value 'SELECT pg_advisory_unlock(hashtext(?))', name
        res == true
      end

      private

      def lock_query(name)
        sanitize_sql_array 'SELECT pg_advisory_lock(hashtext(?))', name
      end

      def connection_pid(con)
        select_value 'SELECT pg_backend_pid()', connection: con
      end

      # We have to manually kill the lock query.
      # Connection pool keeps it alive blocking one connection.
      # Also it would eventually acquire the lock.
      # returns true if lock was acquired
      def recover_from_timeout(pid, name)
        with_dedicated_connection do |con|
          lock = select_one(<<~SQL, pid, name, connection: con)
            SELECT locktype, objid, pid, granted FROM pg_locks \
            WHERE pid = ? AND locktype = 'advisory' AND objid = hashtext(?)
          SQL
          return false unless lock

          if lock['granted']
            logger&.info 'DBLock: Lock was acquired after all'
            true
          else
            res = select_value 'SELECT pg_cancel_backend(?)', pid, connection: con
            logger&.warn 'DBLock: Failed to cancel ungranted lock query' unless res == true
            false
          end
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

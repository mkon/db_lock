module DBLock
  module Adapter
    class Sqlserver < Base
      def lock(name, timeout = 0)
        connection.execute_procedure 'sp_getapplock', Resource: name,
                                                      LockMode: 'Exclusive',
                                                      LockOwner: 'Session',
                                                      LockTimeout: (timeout * 1000).to_i,
                                                      DbPrincipal: 'public'
        lock = connection.raw_connection.return_code
        lock.zero?
      end

      def release(name)
        connection.execute_procedure 'sp_releaseapplock', Resource: name,
                                                          LockOwner: 'Session',
                                                          DbPrincipal: 'public'
        lock = connection.raw_connection.return_code
        lock.zero?
      end
    end
  end
end

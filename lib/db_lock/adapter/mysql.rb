module DBLock
  module Adapter
    class MYSQL < Base
      def lock(name, timeout = 0)
        res = select_value 'SELECT GET_LOCK(?, ?)', name, timeout
        res == 1
      end

      def release(name)
        res = select_value 'SELECT RELEASE_LOCK(?)', name
        res == 1
      end
    end
  end
end

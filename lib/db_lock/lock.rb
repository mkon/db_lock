require 'digest/md5'

module DBLock
  module Lock
    extend self

    def get(name, timeout = 0, &block)
      DBLock.with_lock(name, timeout, &block)
    end

    def locked?
      DBLock.send(:locked?)
    end
  end
end

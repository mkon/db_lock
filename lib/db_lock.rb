require 'digest/md5'

module DBLock
  extend self

  autoload :Adapter, 'db_lock/adapter'
  autoload :Lock, 'db_lock/lock'

  class AlreadyLocked < StandardError; end

  attr_writer :db_handler

  def db_handler
    # this must be an active record base object or subclass
    @db_handler || ActiveRecord::Base
  end
end

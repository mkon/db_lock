require 'active_support'
require 'digest/md5'

module DBLock
  autoload :Adapter, 'db_lock/adapter'
  autoload :Lock, 'db_lock/lock'
  autoload :Locking, 'db_lock/locking'

  extend Locking

  class AlreadyLocked < StandardError; end

  attr_writer :db_handler

  def self.db_handler
    # this must be an active record base object or subclass
    @db_handler || ActiveRecord::Base
  end

  custom_deprecator = ActiveSupport::Deprecation.new('1.0.0', 'DBLock')
  ActiveSupport::Deprecation.deprecate_methods(DBLock::Lock, get: 'use DBLock.with_lock instead', deprecator: custom_deprecator)
  ActiveSupport::Deprecation.deprecate_methods(DBLock::Lock, locked?: 'will be removed without replacement', deprecator: custom_deprecator)
end

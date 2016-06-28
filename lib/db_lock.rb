module DBLock
  extend self

  autoload :Adapter, "db_lock/adapter"

  class AlreadyLocked < StandardError; end

  attr_accessor :db_handler

  def db_handler
    # this must be an active record base object or subclass
    @db_handler || ActiveRecord::Base
  end

  class Lock
    class << self
      def get(name, timeout=0)
        timeout = timeout.to_f # catches nil
        timeout = 0 if timeout < 0
        raise "Invalid lock name: #{name.inspect}" if name.empty?
        raise AlreadyLocked.new("Already lock in progress") if locked?

        name = prefixed_lock_name(name)

        if Adapter.lock(name, timeout)
          @locked = true
          yield
        else
          raise AlreadyLocked.new("Unable to obtain lock '#{name}' within #{timeout} seconds") unless locked?
        end
      ensure
        if locked?
          Adapter.release(name)
        end
        @locked = false
      end

      def locked?
        @locked ||= false
      end

      private

      def prefixed_lock_name(name)
        (name[0] == "." && defined? Rails) ? "#{Rails.application.class.parent_name}.#{Rails.env}#{name}" : name
      end
    end
  end
end

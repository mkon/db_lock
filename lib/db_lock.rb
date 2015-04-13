module DBLock
  class AlreadyLocked < StandardError; end

  class Lock
    class << self
      def get(name, timeout=0)
        timeout = timeout.to_i # catches nil
        timeout = 0 if timeout < 0
        raise "Invalid lock name: #{name.inspect}" if name.empty?
        raise AlreadyLocked.new("Already lock in progress") if locked?

        name = prefixed_lock_name(name)

        sql = ActiveRecord::Base.send(:sanitize_sql_array, ["SELECT GET_LOCK(?, ?)", name, timeout])
        lock = ActiveRecord::Base.connection.execute(sql)
        if @locked = (lock and lock.first and lock.first[0] == 1)
          yield
        else
          raise AlreadyLocked.new("Unable to obtain lock '#{name}' within #{timeout} seconds") unless locked?
        end
      ensure
        if locked?
          sql = ActiveRecord::Base.send(:sanitize_sql_array, ["SELECT RELEASE_LOCK(?)", name])
          ActiveRecord::Base.connection.execute(sql)
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

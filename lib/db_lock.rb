module DBLock
  class AlreadyLocked < StandardError; end

  class Lock
    class << self
      def get(name, timeout=0)
        timeout = timeout.to_i # catches nil
        timeout = 0 if timeout < 0
        raise "invalid lock name: #{name.inspect}" if !name or name.to_s.length == 0
        raise AlreadyLocked.new("Already lock in progress") if locked?
        name = prefixed_lock_name(name)
        res = ActiveRecord::Base.connection.execute("SELECT GET_LOCK('#{name}', #{timeout})")
        if @locked = (res and res.first and res.first[0] == 1)
          yield
        else
          raise AlreadyLocked.new("Unable to obtain lock '#{name}' within #{timeout} seconds") unless @locked
        end
      ensure
        ActiveRecord::Base.connection.execute("SELECT RELEASE_LOCK('#{name}')") if @locked
        @locked = false
      end

      def locked?
        @locked ||= false
      end

    private

      def prefixed_lock_name(name)
        if name[0] == "." and defined? Rails
          name = "#{Rails.application.class.parent_name}#{name}"
        else
          name
        end
      end
    end
  end
end

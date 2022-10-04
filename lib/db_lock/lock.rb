require 'digest/md5'

module DBLock
  module Lock
    extend self

    def get(name, timeout = 0)
      timeout = timeout.to_f # catches nil
      timeout = 0 if timeout.negative?

      raise "Invalid lock name: #{name.inspect}" if name.empty?
      raise AlreadyLocked, 'Already lock in progress' if locked?

      name = generate_lock_name(name)

      if Adapter.lock(name, timeout)
        @locked = true
        yield
      else
        raise AlreadyLocked, "Unable to obtain lock '#{name}' within #{timeout} seconds" unless locked?
      end
    ensure
      Adapter.release(name) if locked?
      @locked = false
    end

    def locked?
      @locked ||= false
    end

    private

    def generate_lock_name(name)
      name = "#{rails_app_name}.#{Rails.env}#{name}" if name[0] == '.' && defined? Rails
      # reduce lock names of > 64 chars in size
      # MySQL 5.7 only supports 64 chars max, there might be similar limitations elsewhere
      name = "#{name.chars.first(15).join}-#{Digest::MD5.hexdigest(name)}-#{name.chars.last(15).join}" if name.length > 64
      name
    end

    def rails_app_name
      if Gem::Version.new(Rails.version) >= Gem::Version.new('6.0.0')
        Rails.application.class.module_parent_name
      else
        Rails.application.class.parent_name
      end
    end
  end
end

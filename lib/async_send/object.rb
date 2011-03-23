module AsyncSend
  module Object

    def async_send(method, *args)
      self.send_job(method, 0, *args)
    end

    def async_send_with_delay(method, delay, *args)
      self.send_job(method, delay, *args)
    end

    private

    def send_job(method, delay=0, *args)
      if self.respond_to? method
        if AsyncSend.config.pool.nil?
          self.send(method, *args)
        else
          job = {
            :class => self.class.to_s,
            :id => self.id,
            :args => args,
            :method => method.to_s
          }.to_json

          AsyncSend.config.pool.use(AsyncSend.config.tube)
          AsyncSend.config.pool.put(job, 65536, delay)
        end
      else
        raise NoMethodError "undefined method `#{method.to_s}' for #{self.to_s}"
      end
    end

  end
end

module AsyncSend
  module Object

    def async_send(method, *args)

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
          AsyncSend.config.pool.put(job)
        end

      else
        raise NoMethodError "undefined method `#{method.to_s}' for #{self.to_s}"
      end
    end

  end
end

module AsyncSend
  module Object
    
    def async_send(method, *args)

      if self.respond_to? method 
        job = {
          :class => self.class.to_s,
          :id => self.id,
          :args => args,
          :method => method.to_s
        }.to_json

        AsyncSend.config.pool.use(AsyncSend.config.tube)
        AsyncSend.config.pool.put(job)
      else
        # !!TODO: Handle invalid method
        puts 'Invalid method'
      end
    end

  end
end

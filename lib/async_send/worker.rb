module AsyncSend
  class Worker

    def self.run
      puts "Starting async_send worker"
      AsyncSend.config.pool.watch(AsyncSend.config.tube)
      loop do
        if job = AsyncSend.config.pool.reserve
          begin
            puts job.body
            data = ActiveSupport::JSON.decode(job.body)
            object = Kernel.const_get(data['class']).find(data['id'])
            object.send(data['method'], *data['args'])
          rescue Exception => e
            puts e.message
            puts e.backtrace.inspect
          ensure
            job.delete
          end
        end
      end
    end

  end
end

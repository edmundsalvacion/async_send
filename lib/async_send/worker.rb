module AsyncSend
  class Worker

    def initialize(opts)
      @opts = opts
    end

    def work

      puts "Starting AsyncSend Worker: pid #{Process.pid}"

      # register signal handlers
      trap('QUIT') { quit }

      AsyncSend.config.pool.watch(AsyncSend.config.tube)
      loop do

        break if quit?

        if job = AsyncSend.config.pool.reserve
          begin
            @busy = true
            data = ActiveSupport::JSON.decode(job.body)
            object = Kernel.const_get(data['class']).find(data['id'])
            object.send(data['method'], *data['args'])
          rescue Exception => e
            puts e.message
            puts e.backtrace.inspect
          ensure
            job.delete
            @busy = false
          end
        end

      end

    end

    def quit
      puts "RECIEVED QUIT SIGNAL"
      Process.kill('TERM', 0) unless @busy
      @quit = true
    end

    def quit?
      @quit
    end

  end

end

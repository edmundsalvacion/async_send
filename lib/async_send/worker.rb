module AsyncSend
  class Worker

    def initialize(opts)
      @opts = opts
    end

    def work

      puts "Starting AsyncSend Worker: pid #{Process.pid}"
      puts "Rails Environment: #{Rails.env}"

      # register signal handlers
      trap('QUIT') { quit }

      AsyncSend.config.pool.watch(AsyncSend.config.tube)
      loop do

        break if quit?

        if job = AsyncSend.config.pool.reserve
          begin
            @busy = true
            data = ActiveSupport::JSON.decode(job.body)

            puts "Job Recieved #{Time.now}"
            puts data
            puts "\n"

            unless data['embedded']
              object = Kernel.const_get(data['class']).find(data['id'])
            else
              parent = Kernel.const_get(data['parent_class']).find(data['parent_id'])
              object = parent.send(data['relation_key']).find(data['id'])
            end

            object.send(data['method'], *data['args'])

          rescue Exception => e
            puts "Job Error #{Time.now}"
            puts e.message
            puts e.backtrace
            puts "\n"
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

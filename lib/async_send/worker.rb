module AsyncSend
  class Worker

    def initialize(opts)
      @opts = opts
    end

    def work
      puts "Starting AsyncSend Worker: pid #{Process.pid} - #{Time.now}"
      puts "Rails Environment: #{Rails.env}\n\n"

      trap('TERM') { term }
      trap('QUIT') { term }

      AsyncSend.config.pool.watch(AsyncSend.config.tube)
      loop do
        break if term?

        if job = AsyncSend.config.pool.reserve
          begin
            @busy = true
            AsyncSend::Worker.run_job(job.body)
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

    def term
      puts "Request to TERM #{Time.now}"
      abort("Aborting process #{Time.now}") unless @busy
      @term = true
    end

    def term?
      @term
    end

    def self.run_job(payload)
      data = ActiveSupport::JSON.decode(payload)

      puts "Job Recieved #{Time.now} ----------------------------\n"
      puts data
      puts "\n"

      unless data['embedded']
        object = Kernel.const_get(data['class']).find(data['id'])
      else
        parent = Kernel.const_get(data['parent_class']).find(data['parent_id'])
        object = parent.send(data['relation_key']).find(data['id'])
      end

      object.send(data['method'], *data['args'])
    end

  end

end

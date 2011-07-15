module AsyncSend
  class Worker

    def initialize(opts)
      @opts = opts
    end

    def work
      AsyncSend.config.logger.info "\nStarting AsyncSend Worker: pid #{Process.pid} - #{Time.now}\n"
      AsyncSend.config.logger.info "\nRails Environment: #{Rails.env}\n"

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
            AsyncSend.config.logger.error "\nJob Error #{Time.now}\n"
            AsyncSend.config.logger.error e.message
            AsyncSend.config.logger.error e.backtrace
          ensure
            job.delete
            @busy = false
          end
        end
      end

    end

    def term
      AsyncSend.config.logger.info "\nRequest to TERM #{Time.now}\n"
      abort("Aborting process #{Time.now}") unless @busy
      @term = true
    end

    def term?
      @term
    end

    def self.run_job(payload)
      data = ActiveSupport::JSON.decode(payload)

      AsyncSend.config.logger.info "\nJob Recieved #{Time.now} ----------------------------\n"
      AsyncSend.config.logger.info data

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

require "beanstalk-client"

module AsyncSend
  class Config
    include Singleton

    attr_accessor \
      :host,
      :port,
      :tube

    attr_reader :pool

    def from_hash(settings)
      settings.each_pair do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=")
      end
      @settings = settings.dup
    end

    def pool
      @pool ||= _pool(@settings)
    end

    def pool=(pool)
      # !!TODO: Do a check on set
      @pool = pool
    end

    def _pool(settings)
      if settings['host']
        Beanstalk::Pool.new(settings['host'].split(','))
      end
    end 

  end
end

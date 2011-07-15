require 'beanstalk-client'
require 'logger'

module AsyncSend
  class Config
    include Singleton

    attr_accessor \
      :hosts,
      :tube

    attr_reader :pool

    def from_hash(settings)
      settings.each_pair do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=")
      end
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def logger=(file)
      @logger = Logger.new(file)
    end

    def pool
      @pool ||= _pool
    end

    def pool=(pool)
      @pool = pool if pool.is_a?(Beanstalk::Pool)
    end

    def _pool
      if self.hosts
        Beanstalk::Pool.new(self.hosts)
      end
    end

  end
end

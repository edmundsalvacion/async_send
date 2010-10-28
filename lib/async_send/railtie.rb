require "singleton"
require "async_send"
require "async_send/config"
require "rails"

module Rails
  module AsyncSend
    class Railtie < Rails::Railtie

      config.async_send = ::AsyncSend::Config.instance

      initializer "setup async_send configuration" do
        config_file = Rails.root.join('config', 'async_send.yml')
        if config_file.file?
          settings = YAML.load(ERB.new(config_file.read).result)[Rails.env]
          ::AsyncSend.config.from_hash(settings)
        end
      end

      initializer "verify async_send configuration" do
        config.after_initialize do
          begin
            ::AsyncSend.config.pool
          rescue ::Mongoid::Errors::InvalidDatabase => e
            unless Rails.root.join("config", "async.yml").file?
              puts "\nAsyncSend config not found. Create a config file at: config/async_send.yml"
            end
          end
        end
      end

    end
  end
end

module AsyncSend
  module Mongoid
    module Document

      def async_send(method, *args)
        self.async_send_with_delay(method, 0, *args)
      end

      def async_send_with_delay(method, delay=0, *args)

        if self.respond_to? method
          job = {
            :class => self.class.to_s,
            :id => self.id,
            :args => args,
            :method => method.to_s
          }

          if self.embedded?

            # get relation key
            self._parent.relations.each_value do |relation|
              is_embedded = (relation.macro.eql?(:embeds_one) or relation.macro.eql?(:embeds_many))
              if relation.class_name.eql?(self.class.to_s) and is_embedded
                job[:relation_key] = relation.key
                break
              end
            end

            job[:embedded] = true
            job[:parent_id] = self._parent.id.to_s
            job[:parent_class] = self._parent.class.to_s
          end


          unless AsyncSend.config.pool.nil?
            AsyncSend.config.pool.use(AsyncSend.config.tube)
            AsyncSend.config.pool.put(job.to_json, 65536, delay)
          else
            # Run job when no pool has been set
            AsyncSend::Worker.run_job(job.to_json)
          end

        else
          raise NoMethodError "undefined method `#{method.to_s}' for #{self.to_s}"
        end
      end

    end
  end
end

#::Mongoid::Document.extend(AsyncSend::Mongoid::Document)

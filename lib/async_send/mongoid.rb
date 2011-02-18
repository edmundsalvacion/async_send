module AsyncSend
  module Mongoid
    module Document

      def async_send(method, *args)

        if self.respond_to? method

          if AsyncSend.config.pool.nil?
            self.send(method, *args)
          else
            job = {
              :class => self.class.to_s,
              :id => self.id,
              :args => args,
              :method => method.to_s
            }

            if self.embedded?

              # get relation key
              self._parent.relations.each do |relation|
                is_embedded = relation.macro.eql?(:embeds_one) or relation.macro.eql?(:embeds_many)
                if relation.class_name.eql?(self.class.to_s) and is_embedded
                  job[:relation_key] = relation.key
                  break
                end
              end

              job[:embedded] = true
              job[:parent_id] = self._parent.id.to_s
              job[:parent_class] = self._parent.class.to_s
            end

            AsyncSend.config.pool.use(AsyncSend.config.tube)
            AsyncSend.config.pool.put(job.to_json)
          end

        else
          raise NoMethodError "undefined method `#{method.to_s}' for #{self.to_s}"
        end
      end

    end
  end
end

::Mongoid::Document.extend(AsyncSend::Mongoid::Document)

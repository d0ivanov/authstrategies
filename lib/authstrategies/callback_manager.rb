module CallbackManager
  def self.included(base)
    class << base
      private
      @@callbacks = {}

      public
      def self.registered? hook
        @@callbacks.has_key? hook
      end

      def register hook, &block
        if @@callbacks[hook].class == Array
          @@callbacks[hook].push block
        else
          @@callbacks[hook] = [block]
        end
      end

      def call hook, args = []
        if @@callbacks.has_key? hook
          @@callbacks[hook].each do |callback|
            callback.call(args)
          end
        end
      end
    end
  end
end

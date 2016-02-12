require "sinatra/base"

module Sinatra
  module AuthStrategies
    module Helpers
      def authstrategies
        env["authstrategies"]
      end

      def session
        env["authstrategies.session"]
      end

      def cookies
        env["authstrategies.session.manager"].cookies
      end

      def set_cookie(name, value, path, expire)
        env["authstrategies.session.manager"].set name, value, path, expire
      end

      def delete_cookie(*names)
        env["authstrategies.session.manager"].delete names
      end

      def authenticate!(name = :password)
        strategy = strategy(name)
        strategy.authenticate! unless strategy.nil?
      end

      def authenticated?
        !cookies[:user_id].nil?
      end

      def strategy(name)
        authstrategies.find(-> { [] }) {|key, strategy| key == name}.last
      end
    end
  end
end

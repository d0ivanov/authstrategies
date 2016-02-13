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

      def authenticate!
        status, user = authstrategies.authenticate
        if status == :success
          session[:current_user] = user.id
          redirect "/", 200
        else
          redirect "/", 401
        end
      end

      def authenticated?
        !current_user.nil?
      end

      def current_user
        session[:current_user]
      end

      def logout
        session[:current_user] = nil
        cookies.delete["authstrategies.session".to_sym]
      end
    end
  end
end

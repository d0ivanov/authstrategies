require 'helpers'
require 'authstrategies/manager'
require 'authstrategies/session'
require 'authstrategies/db_manager'

module Sinatra
  module AuthStrategies
    def self.registered(app)
      include ::AuthStrategies::DatabaseManager.new.get app.settings.db_adapter

      app.use ::AuthStrategies::Session, app.settings.cookie_secret
      app.helpers Helpers

      app.use ::AuthStrategies::Manager do
        register :password do
          def valid?
            @params["email"] && @params["password"]
          end

          def authenticate!
            user = User.find_by email: @params["email"]
            if !user.nil? && user.authenticate(@params["password"])
              return success! user
            end
            fail!
          end
        end

        register :plain_http do
          def valid?
            @auth = Rack::Auth::Basic::Request.new(@env)
            @auth.provided? && @auth.basic?
          end

          def authenticate!
            email, password = @auth.credentials
            user = User.find_by email: email

            if !user.nil? && user.authenticate(password)
              return success! user
            end
            fail!
          end
        end
      end

      app.post '/login/?' do
        authenticate!
      end

      app.post '/logout/?' do
        logout
        redirect "/"
      end
    end
  end
end

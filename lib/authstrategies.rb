require 'helpers'
require 'authstrategies/manager'
require 'authstrategies/session'
require 'authstrategies/db_manager'

module Sinatra
  module AuthStrategies
    def self.registered(app)

      app.helpers Helpers
      adapter = ::AuthStrategies::DatabaseManager.new.get

      app.use ::AuthStrategies::Session, "1c77f04ac6d628419f21bfc7ebabce6969d13caa"
      app.use ::AuthStrategies::Manager do
        register :password do
          def valid?
            params[:email] && params[:password]
          end

          def authenticate!
            user = adapter.find_by_emal params[:email]

            if !user.nil? && user.authenticate(params[:password])
              session[:current_user] = user.id
            end
            redirect "/"
          end
        end

        register :plain_http do
          def valid?
          end

          def authenticate!
          end
        end
      end

      app.post '/login/?' do
        user = adapter.find_by_email(params[:email])
        if !user.nil? && user.authenticate(params[:password])
          set_cookie :user_id, user.id, "/", Time.now + 24 * 3600
          redirect '/authenticated'
        else
          redirect '/unauthenticated'
        end
      end
    end
  end
end

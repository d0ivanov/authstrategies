require 'auth_helpers'
require 'authstrategies/manager'
require 'authstrategies/strategy'
require 'authstrategies/db_manager'

module Sinatra
  module AuthStrategies
    def self.registered(app)
      app.helpers AuthHelpers
      adapter = ::AuthStrategies::DatabaseManager.new.get

      app.post '/login/?' do
        user = adapter.find_by_email(params[:email])
        if !user.nil? && user.authenticate(params[:password])
          redirect '/authenticated'
        else
          redirect '/unauthenticated'
        end
      end
    end
  end
end

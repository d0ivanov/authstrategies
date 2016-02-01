require "sinatra/base"
require "authstrategies"
require "authstrategies/strategy"

class User < Struct.new(:username, :password)
end

MOCK_USERS = [User.new("test", "pass"), User.new("test2", "pass2")]

class MockApp < Sinatra::Base
  helpers Sinatra::AuthStrategies::AuthHelper
  use AuthStrategies::Manager do
    register :password do

      def valid?
        params[:username] && params[:password]
      end

      def authenticate!
        user = MOCK_USERS.find {|u| u.username == params["username"]}

        !user.nil? && user.password == params["password"]
      end
    end
  end

  post "/login/?" do
    if authenticate!
      redirect "/authenticated"
    end

    redirect "/unauthenticated"
  end

  get "/authenticated" do
  end

  get "/unauthenticated" do
  end
end

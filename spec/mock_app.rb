require "sinatra/base"
require "sinatra/activerecord"
require "authstrategies"

class MockApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  set :database, {adapter: "sqlite3", database: "test.sqlite3"}
  set :db_adapter, :active_record
  set :cookie_secret, "1c77f04ac6d628419f21bfc7ebabce6969d13caa"

  register Sinatra::AuthStrategies

  get "/authenticated" do
    if !authenticated?
      redirect "/unauthenticated"
    end

    "Success!"
  end

  get "/unauthenticated" do
  end
end

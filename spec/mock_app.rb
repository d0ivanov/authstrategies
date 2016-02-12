require "sinatra/base"
require "sinatra/activerecord"
require "authstrategies"

class MockApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  set :database, {adapter: "sqlite3", database: "test.sqlite3"}

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

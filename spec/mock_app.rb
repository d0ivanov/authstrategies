require "sinatra/base"
require "sinatra/activerecord"
require "authstrategies"

class MockApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :database, {adapter: "sqlite3", database: "test.sqlite3"}

  use AuthStrategies::Manager
  register Sinatra::AuthStrategies
end

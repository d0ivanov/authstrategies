require "sinatra/base"
require "sinatra/activerecord"
require "authstrategies"

class MockApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :database, {adapter: "sqlite3", database: "test.sqlite3"}

  set :db_adapter, :active_record
  include AuthStrategies::DatabaseManager.new.get :active_record

  set :cookie_secret, "35ad9acea6e5c22a0f8850774d17bbcac1ad7923"
  register Sinatra::AuthStrategies

  get "/authenticated" do
    if !authenticated?
      redirect "/unauthenticated"
    end

    user = User.find_by(id: current_user)
    user.email unless user.nil?
  end

  get "/unauthenticated" do
  end
end

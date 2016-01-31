require "sinatra/base"
require "authstrategies"
require "authstrategies/middleware"

class MockApp < Sinatra::Base
  register Sinatra::AuthStrategies
end

require "sinatra/base"
require "authstrategies"

class MockApp < Sinatra::Base
  register Sinatra::AuthStrategies
end

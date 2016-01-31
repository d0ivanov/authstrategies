require "sinatra"
require "rack/test"
require "rspec"
require "mock_app"

ENV["RACK_ENV"] = "test"

module RSpecMixin
  include Rack::Test::Methods

  def app()
    MockApp
  end
end

RSpec.configure { |c| c.include RSpecMixin }

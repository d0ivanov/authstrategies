require 'sinatra/base'

require_relative 'base'

module Authstrategies
	private
		class Middleware < Sinatra::Base
			register Base
		end
end

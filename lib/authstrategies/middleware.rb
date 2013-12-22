require 'sinatra/base'

module Authstrategies
	private
		class Middleware < Sinatra::Base
			register Base
		end
end

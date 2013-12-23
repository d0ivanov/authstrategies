module Authstrategies
	class Middleware < Sinatra::Base
		register Base
		register RememberMe
	end
end

module Authstrategies
	class Middleware < Sinatra::Base
		register Base
		register Base::RememberMe
	end
end

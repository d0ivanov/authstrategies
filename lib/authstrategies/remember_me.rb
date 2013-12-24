module Authstrategies
	class RememberMeStrategy < Warden::Strategies::Base
		def valid?
			!!(request.cookies["authstrategies"])
		end

		def authenticate!
			user = User.find_by_remember_token(request.cookies["authstrategies"])
			if user && user.remember_me
				success!(user)
			end
			fail!('')
		end
	end
end
